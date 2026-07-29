# dotfiles

Personal Nix-powered macOS configuration. Terminal-first workflow.

Declarative, reproducible setup managed entirely through Nix flakes. Includes system preferences, CLI tools, GUI apps, editor configs, and shell customizations. One `darwin-rebuild switch` to bootstrap or restore a machine.

## Prerequisites

**Nix** via [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer)

## Installation

```bash
git clone git@github.com:SviatoslavIvanov/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
darwin-rebuild switch --flake .
```

> **Note:** This config references a private `dotfiles-private` flake input.
> Fork this repo and remove it from `flake.nix` or replace with your own secrets management.

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
| **sd** | Simple `sed` |
| **dust** | `du` with visualization |
| **tree** | Directory tree |

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
| **cursor** | AI-powered editor |
| **VS Code** | When you need extensions |
| **JetBrains Toolbox** | JetBrains IDEs manager |

### DevOps & Containers

| Tool | Description |
|------|-------------|
| **orbstack** | Docker & Linux VMs for macOS |
| **lazydocker** | Docker TUI |
| **ansible** | Infrastructure automation (pipelining enabled) |
| **utm** / **parallels** | Virtual machines |

### Data & HTTP

| Tool | Description |
|------|-------------|
| **jq** / **yq** | JSON/YAML processors |
| **fx** | Interactive JSON viewer |
| **httpie** | HTTP client |
| **yaak** | API client |

### Utilities

| Tool | Description |
|------|-------------|
| **btop** | System monitor |
| **tokei** | Lines of code counter |
| **glow** | Markdown viewer |
| **ouch** | Universal archiver |
| **agenix-cli** | Secrets management |
| **coreutils** | GNU core utilities |
| **gnused** | GNU sed |
| **curl** / **wget** | HTTP clients |

### AI Tools

| Tool | Description |
|------|-------------|
| **claude** | Claude desktop app |
| **claude-code** | Claude CLI agent |
| **codex** | OpenAI Codex CLI |
| **gemini-cli** | Google Gemini CLI |
| **ollama** | Local LLMs |

### Nix Tooling

| Tool | Description |
|------|-------------|
| **nixd** | Nix LSP |
| **nil** | Nix LSP (alternative) |
| **nixpkgs-fmt** | Formatter |
| **statix** | Linter |
| **deadnix** | Dead code finder |

## GUI Apps (via Homebrew)

**Productivity:** Raycast, Obsidian, Capacities, Todoist, Raindrop.io, Linear

**Browsers:** Arc, Google Chrome

**Communication:** Telegram, WhatsApp, Signal, Discord, Mattermost, Zoom

**Media:** Spotify, Tidal, Qobuz, IINA, OBS

**Design:** Figma

**Security:** 1Password (+ CLI + shell plugins), AmneziaVPN, Pritunl

**Gaming:** Steam, Moonlight

**Utilities:** Alt-Tab, Ice (menu bar), Mac Mouse Fix, balenaEtcher, RustDesk, qBittorrent, VIA (keyboard)

## Fonts

- JetBrains Mono Nerd Font
- Monaspace Nerd Font
- Nerd Fonts Symbols

## mise Tasks

Dev tasks for this repo (`mise.toml`):

```bash
mise run fmt          # Format .nix files
mise run check        # Lint with statix
mise run dead         # Find dead code
mise run clean        # Remove dead code
mise run flake-check  # Validate flake
mise run lint         # Run all checks
```

## Usage

Apply changes:
```bash
darwin-rebuild switch --flake .
# or shell alias:
rebuild
```

Update all inputs:
```bash
nix flake update
# or:
update
```

Clean Nix store:
```bash
nix-collect-garbage -d
# or:
cleanup
```

## macOS Defaults

Automatically configured:

- **Dock:** auto-hide, no recent apps, stable spaces order
- **Finder:** show hidden files, extensions, path bar, status bar
- **Keyboard:** fast key repeat (2/15), no auto-corrections
- **Security:** Touch ID for sudo, guest login disabled
- **Screenshots:** saved to `~/Pictures/Screenshots`
