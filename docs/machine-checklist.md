# Machine checklist

One-off manual steps for physical machines. These are not code changes, so they
live here rather than in the doto backlog.

## Apply on existing machines (one-off, manual)

The defaults changes only affect future `dot macos` runs; already-applied
settings need reverting by hand:

- Re-enable download quarantine: `defaults delete com.apple.LaunchServices LSQuarantine`
- Laptops: turn off automatic login in System Settings > Users & Groups.
- Mac mini: keep auto-login by creating `src/topics/macos/defaults-local/login.yaml`
  (gitignored, applied automatically by `dot macos`):

  ```yaml
  ---
  description: Local overrides
  sudo: true
  data:
    com.apple.loginwindow:
      autoLoginUser: <your-username>
  ```

- If the LocalStack token in `~/.localrc` was ever live, rotate it and delete
  the commented-out line (it was never committed, this is just hygiene).
