# Add Homebrew to PATH on M* Macs
if [[ "$(uname -m)" == "arm64" ]]; then
  export PATH="/opt/homebrew/bin:${PATH}"
fi