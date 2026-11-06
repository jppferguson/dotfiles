#!/usr/bin/env bash
#
# Attach a local file to a doto task from any machine, without the file's
# bytes passing through the agent's conversation.
#
# The doto MCP tool upload_attachment_from_path reads paths on the doto
# server, so it cannot see files on another machine, and upload_attachment
# makes the model write the whole file into the tool call as base64. This
# script POSTs the file as multipart to doto-mcp's upload route
# (POST /mcp/attachments/<taskId>), authenticated with the same bearer token
# the doto MCP uses, so the caller gets the same project access as a tool call.
#
# Usage: doto-attach.sh <taskId> <file> [--actor <actor>] [--comment <commentId>] [--type <mime>]
#   <taskId>  full task UUID or a unique prefix (e.g. ed24f7cc)
#   --actor   who is attaching it (default: $DOTO_ACTOR, else agent:claude-code)
#   --comment attach the file beneath an existing comment on the same task
#   --type    MIME type override (default: inferred from the file extension)
#
# Environment:
#   DOTO_MCP_TOKEN  bearer token for the doto MCP (required)
#   DOTO_URL        doto base URL (default: https://doto.personal.os)
#
# Output: on success, one line `attached <filename> to <taskId>: <attachmentId>`
# on stdout and exit 0. On any failure, a message on stderr and exit 1.

set -euo pipefail

max_bytes=$((10 * 1024 * 1024))

fail() {
  echo "doto-attach: $*" >&2
  exit 1
}

usage="usage: doto-attach.sh <taskId> <file> [--actor <actor>] [--comment <commentId>] [--type <mime>]"

positional=()
actor="${DOTO_ACTOR:-agent:claude-code}"
comment_id=""
mime_type=""
while [ $# -gt 0 ]; do
  case "$1" in
    --actor | --comment | --type)
      [ $# -ge 2 ] || fail "$1 needs a value"
      case "$1" in
        --actor) actor="$2" ;;
        --comment) comment_id="$2" ;;
        --type) mime_type="$2" ;;
      esac
      shift 2
      ;;
    -h | --help)
      echo "$usage"
      exit 0
      ;;
    -*) fail "unknown option: $1. $usage" ;;
    *)
      positional+=("$1")
      shift
      ;;
  esac
done

[ ${#positional[@]} -eq 2 ] || fail "$usage"
task_id="${positional[0]}"
file="${positional[1]}"

[ -n "${DOTO_MCP_TOKEN:-}" ] || fail "DOTO_MCP_TOKEN is not set. Export the doto MCP bearer token (the one in your MCP config) and retry."
[ -e "$file" ] || fail "file not found: $file"
[ -f "$file" ] || fail "not a regular file: $file"
[ -r "$file" ] || fail "file is not readable: $file"

size=$(wc -c <"$file" | tr -d ' ')
if [ "$size" -gt "$max_bytes" ]; then
  fail "$file is $size bytes, over doto's 10MB attachment limit"
fi

filename=$(basename "$file")
if [ -z "$mime_type" ]; then
  extension=$(printf '%s' "${filename##*.}" | tr '[:upper:]' '[:lower:]')
  case "$extension" in
    png) mime_type=image/png ;;
    jpg | jpeg) mime_type=image/jpeg ;;
    gif) mime_type=image/gif ;;
    webp) mime_type=image/webp ;;
    svg) mime_type=image/svg+xml ;;
    pdf) mime_type=application/pdf ;;
    doc) mime_type=application/msword ;;
    docx) mime_type=application/vnd.openxmlformats-officedocument.wordprocessingml.document ;;
    xls) mime_type=application/vnd.ms-excel ;;
    xlsx) mime_type=application/vnd.openxmlformats-officedocument.spreadsheetml.sheet ;;
    ppt) mime_type=application/vnd.ms-powerpoint ;;
    pptx) mime_type=application/vnd.openxmlformats-officedocument.presentationml.presentation ;;
    txt | log) mime_type=text/plain ;;
    md) mime_type=text/markdown ;;
    csv) mime_type=text/csv ;;
    html | htm) mime_type=text/html ;;
    zip) mime_type=application/zip ;;
    gz | tgz) mime_type=application/gzip ;;
    tar) mime_type=application/x-tar ;;
    json) mime_type=application/json ;;
    xml) mime_type=application/xml ;;
    yaml | yml) mime_type=text/yaml ;;
    *) fail "cannot infer a MIME type for $filename; pass --type <mime> (doto accepts images, PDF, Office, text, archives, JSON, XML and YAML)" ;;
  esac
fi

base_url="${DOTO_URL:-https://doto.personal.os}"
url="${base_url%/}/mcp/attachments/$task_id"

form=(-F "file=@$file;type=$mime_type;filename=$filename" -F "createdBy=$actor")
[ -z "$comment_id" ] || form+=(-F "commentId=$comment_id")

response_file=$(mktemp)
trap 'rm -f "$response_file"' EXIT

# The token goes in via a header file on stdin so it never appears in the process list.
if ! status=$(printf 'Authorization: Bearer %s\n' "$DOTO_MCP_TOKEN" |
  curl --silent --show-error --max-time 120 \
    --header @- \
    --output "$response_file" \
    --write-out '%{http_code}' \
    "${form[@]}" \
    "$url"); then
  fail "could not reach $base_url"
fi

body=$(cat "$response_file")
error=$(printf '%s' "$body" | sed -n 's/.*"error"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

case "$status" in
  201)
    attachment_id=$(printf '%s' "$body" | sed -n 's/.*"id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    echo "attached $filename to $task_id: $attachment_id"
    ;;
  401 | 403) fail "refused ($status): ${error:-unauthorised}. Check DOTO_MCP_TOKEN." ;;
  404) fail "${error:-task not found: $task_id}. Check the task id; a task in a project your token cannot read also reads as not found." ;;
  413) fail "${error:-file too large}" ;;
  *) fail "upload failed ($status): ${error:-$body}" ;;
esac
