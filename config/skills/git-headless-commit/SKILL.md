# Git Commit in Headless Environments

When working in headless or containerized environments where GPG agent/tty context is missing, standard GPG signed commits may fail.

## Troubleshooting
If `git commit` yields:
```
error: gpg failed to sign the data
fatal: failed to write commit object
```

Bypass GPG signing for the specific commit:
```bash
git commit --no-gpg-sign -m "type(scope): message"
```
