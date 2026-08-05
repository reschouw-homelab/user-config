# user-config

My personal config preferences, kept in one place so I don't have to
re-configure every machine by hand. Nothing serious here, just dotfiles:
generic aliases, a vim setup, a git-aware bash prompt, and a little bootstrap
script to wire it all together. Theoretically Mac and Linux friendly.

## What's in here

| Path | What it does |
| --- | --- |
| `setup.sh` | Idempotent bootstrap: symlinks configs, creates vim dirs, installs a few tools. |
| `utility.sh` | Reusable helper functions used by `setup.sh` (symlink/dir/clone/brew helpers). |
| `bashrc/*.conf` | Bash fragments sourced on every interactive shell (aliases, PATH, prompt, auto-update). |
| `vim/vimrc` | Vim configuration (symlinked to `~/.vimrc`). |
| `git/config` | Git defaults (editor, user, `gh` credential helper). |
| `terraform/terraformrc` | Terraform plugin cache dir (symlinked to `~/.terraformrc`). |
| `gh/config.yml` | GitHub CLI preferences. |

## Getting started on a new machine

```bash
git clone git@github.com:reschouw-homelab/user-config.git ~/.config
~/.config/setup.sh
```

`setup.sh` is safe to re-run; it only changes what needs changing. It also adds
a line to `~/.bashrc` that sources everything under `~/.config/bashrc/*.conf`,
so new shells pick up the aliases and prompt automatically.

## Auto-updates

`bashrc/check-updates.conf` runs on every interactive shell. It fetches the
repo and, if the local copy is behind, does a `git reset --hard origin/master`
and re-runs `setup.sh`.

**Heads up:** that hard reset means anything you change locally that isn't
committed and pushed will be blown away on the next shell. That's intentional,
the repo is the source of truth. If you tweak something, commit and push it.

## Notes

- Job-specific or otherwise sensitive config deliberately lives outside this
  repo. This is personal preferences only.
- Secrets and machine-specific junk are handled in `.gitignore`
  (e.g. `gh/hosts.yml`, various app state dirs).
