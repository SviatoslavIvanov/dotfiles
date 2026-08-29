# dotfiles

Personal Nix-powered macOS configuration. Terminal-first workflow.

Nix pins the system configuration and CLI tools. Git pins the writable editor
and tool-manager lock files. Homebrew, App Store, vendor-managed apps,
credentials, and application data remain external state and are intentionally
not presented as fully reproducible.

## Prerequisites

1. Install **Nix** with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer).
2. Install and sign in to **1Password**, then enable its CLI integration and
   SSH Agent. The private flake input must be accessible before nix-darwin can
   install the declared applications and activate secrets.
3. Verify GitHub SSH access with `ssh -T git@github.com`.

## Installation

```bash
export DOTFILES_DIR="$HOME/Developer/github.com/SviatoslavIvanov/dotfiles"
mkdir -p "$(dirname "$DOTFILES_DIR")"
git clone https://github.com/SviatoslavIvanov/dotfiles.git "$DOTFILES_DIR"
cd "$DOTFILES_DIR"
nix flake archive --no-update-lock-file .
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#svyat-mac --no-update-lock-file
```

Home Manager keeps `DOTFILES_DIR` set to this canonical working tree after the
first activation. Writable lock-file links and maintenance commands derive from
the same value.

> **Note:** This config references a private `dotfiles-private` flake input.
> Forks must remove both the input and its Darwin/Home Manager module references
> from `flake.nix`, or replace them with their own private configuration.

## What's Inside

### Stack

| Component | Purpose |
|-----------|---------|
| **Nix Flakes** | Reproducible, declarative system configuration |
| **nix-darwin** | macOS system settings management |
| **Home Manager** | User environment and dotfiles |
| **Stylix** + **Catppuccin Mocha** | Unified theming across all apps |
| **Homebrew** (via nix-homebrew) | GUI apps and casks |
| **mise** | Runtime version manager + task runner |

### Structure

```
.
├── flake.nix           # Entry point, inputs and outputs
├── flake.lock          # Pinned dependency versions
├── mise.toml           # Dev tasks (lint, format, check)
├── modules/
│   ├── darwin.nix      # macOS settings, fonts, Homebrew casks
│   ├── home.nix        # Home Manager entry point
│   ├── packages.nix    # CLI tools and yazi config
│   ├── shell.nix       # Zsh, fzf, zoxide, bat, eza
│   ├── terminal.nix    # Ghostty, tmux
│   ├── git.nix         # Git, delta, lazygit, gh
│   ├── aerospace.nix   # AeroSpace workspaces and window rules
│   ├── stylix.nix      # Shared fonts and base16 theme
│   ├── zed.nix         # Zed editor settings
│   └── claude-code.nix # Claude Code settings
└── configs/            # Non-Nix configs (nvim, p10k)
```

## CLI Tools

### Shell & Navigation

| Tool | Description |
|------|-------------|
| **zsh** | Shell with vi-mode, fzf-tab, fast-syntax-highlighting |
| **powerlevel10k** | Prompt theme |
| **fzf** | Fuzzy finder |
| **zoxide** | Smarter `cd` with frecency |
| **atuin** | Shell history with fuzzy search |
| **bat** | `cat` with syntax highlighting |
| **eza** | `ls` with icons and git status |
| **yazi** | Terminal file manager with image previews |
| **fd** | Fast `find` |
| **ripgrep** | Fast `grep` |
| **tree-sitter** | Parser CLI used by Neovim |
| **sd** | Simple `sed` |
| **dust** | `du` with visualization |

### Git

| Tool | Description |
|------|-------------|
| **lazygit** | Git TUI |
| **delta** | Syntax-highlighted side-by-side diffs |
| **gh** | GitHub CLI |
| **gh-dash** | PR and issues dashboard |
| **git-lfs** | Large File Storage |

### Terminal & Multiplexing

| Tool | Description |
|------|-------------|
| **ghostty** | GPU-accelerated terminal |
| **tmux** | Multiplexer with vim-style navigation, resurrect, continuum |

### Editors & IDEs

| Tool | Description |
|------|-------------|
| **neovim** | LazyVim configuration |
| **zed** | Fast GUI editor (Biome for JS/TS formatting) |
| **VS Code** | When you need extensions |

### DevOps & Containers

| Tool | Description |
|------|-------------|
| **orbstack** | Docker & Linux VMs for macOS |
| **lazydocker** | Docker TUI |
| **ansible** | Infrastructure automation (pipelining enabled) |
| **utm** | Virtual machines |

### Data & HTTP

| Tool | Description |
|------|-------------|
| **jq** / **yq** | JSON/YAML processors |
| **httpie** | HTTP client |

### Utilities

| Tool | Description |
|------|-------------|
| **btop** | System monitor |
| **tokei** | Lines of code counter |
| **glow** | Markdown viewer |
| **ouch** | Universal archiver |
| **ragenix** | Secrets management |
| **openssh** | Homebrew OpenSSH with FIDO2 support |
| **coreutils** | GNU core utilities |
| **gnused** | GNU sed |
| **curl** / **wget** | HTTP clients |

### AI Tools

| Tool | Description |
|------|-------------|
| **claude** | Claude desktop app |
| **claude-code** | Claude CLI agent |
| **codex** | OpenAI Codex CLI |

### Nix Tooling

| Tool | Description |
|------|-------------|
| **nixd** | Nix LSP |
| **nixfmt** | Official Nix formatter |
| **statix** | Linter |
| **deadnix** | Dead code finder |

## GUI Apps (via Homebrew)

**Productivity:** Raycast, Obsidian, Todoist, Raindrop.io, Linear

**Browsers:** Arc, Google Chrome

**Communication:** Telegram, WhatsApp, Signal, Discord, Mattermost, Zoom

**Media:** Spotify, IINA

**Security:** 1Password (+ CLI), AmneziaVPN, Pritunl

**Gaming:** Steam, Moonlight

**Utilities:** Ice (menu bar), Mac Mouse Fix

**Unmanaged exceptions:** qBittorrent stays installed until upstream ships a
Gatekeeper-compliant build; Parallels Desktop uses its vendor installer; VIA
keyboards are configured with the maintained [VIA web app](https://usevia.app/).

## Fonts

- JetBrains Mono Nerd Font
- Monaspace Nerd Font
- Nerd Fonts Symbols

## mise Tasks

Dev tasks for this repo (`mise.toml`):

```bash
mise run fmt          # Format .nix files
mise run fmt-check    # Check Nix formatting
mise run check        # Lint with statix
mise run dead         # Find dead code
mise run clean        # Remove dead code
mise run flake-check  # Validate flake
mise run lua-check    # Check Lua formatting
mise run lock-check   # Validate writable lock files
mise run secret-check # Scan the tree and history for secrets
mise run lint         # Run all checks
```

## Usage

Apply changes:
```bash
rebuild
# or directly:
nix flake archive --no-update-lock-file "$DOTFILES_DIR"
sudo darwin-rebuild switch --flake "$DOTFILES_DIR#svyat-mac" --no-update-lock-file
```

Update all inputs:
```bash
update
# or directly:
nix flake update --flake "$DOTFILES_DIR"
```

List generations and roll back Nix-managed system and Home Manager state:
```bash
sudo darwin-rebuild --list-generations
sudo darwin-rebuild switch --rollback
sudo darwin-rebuild switch --switch-generation <generation>
```

Homebrew, App Store, and vendor-managed application changes are outside Nix
generations and are not reverted by `darwin-rebuild --rollback`.

The mise config/lock and Neovim plugin lock are writable links into
`$DOTFILES_DIR` so their own tools can update them. Git, rather than Nix
generations, is their rollback mechanism.

Collect unreachable Nix store paths without deleting profile generations:
```bash
nix-collect-garbage
```

## macOS Defaults

Automatically configured:

- **Dock:** auto-hide, no recent apps, stable spaces order
- **Finder:** show hidden files, extensions, path bar, status bar
- **Keyboard:** fast key repeat (2/15), no auto-corrections
- **Security:** firewall + stealth mode, Touch ID for sudo, guest login disabled, immediate lock
- **Power:** displays sleep after 10 minutes
- **Updates:** automatic macOS and App Store updates
- **Screenshots:** saved to `~/Pictures/Screenshots`
