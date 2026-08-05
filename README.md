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
| `bashrc/local.conf.example` | Template for machine/job-specific config; copied to the (gitignored) `local.conf` on setup. |
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

## Local, untracked config

Anything machine- or job-specific goes in `bashrc/local.conf`, which is
gitignored. `setup.sh` seeds it from `bashrc/local.conf.example` on a new
machine, and the bashrc loop auto-sources it like any other fragment. Because
it's untracked, the auto-updater's `git reset --hard` leaves it alone, so your
local tweaks survive updates without ever being committed here.

Use it for work aliases, internal hostnames, credential-adjacent settings, or
per-machine PATH tweaks that don't belong in a personal repo.

## Notes

- Job-specific or otherwise sensitive config deliberately lives outside this
  repo (see above). This is personal preferences only.
- Secrets and machine-specific junk are handled in `.gitignore`
  (e.g. `gh/hosts.yml`, various app state dirs).
