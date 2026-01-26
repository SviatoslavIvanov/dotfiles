# dotfiles

Declarative macOS configuration powered by Nix.

## Prerequisites

1. **Nix** — install via [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer):
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```

3. **mise** (optional, for dev tasks):
   ```bash
   curl https://mise.run | sh
   ```

## Installation

```bash
git clone git@github.com:IvanovSvyatoslav/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

> **Note:** This config uses a private `dotfiles-private` flake input for sensitive data.
> Fork this repo and either remove it from `flake.nix` or replace with your own.

Build and apply:
```bash
darwin-rebuild switch --flake .
```

## Stack

| Component | Purpose |
|-----------|---------|
| **Nix Flakes** | Reproducible declarative configuration |
| **nix-darwin** | macOS system settings management |
| **Home Manager** | User environment and dotfiles |
| **Stylix** + **Catppuccin Mocha** | Unified theming across all apps |
| **Homebrew** (via nix-homebrew) | GUI apps and casks |
| **mise** | Runtime version manager + task runner |

## Structure

```
.
├── flake.nix           # Entry point, inputs and outputs
├── flake.lock          # Pinned dependency versions
├── mise.toml           # Dev tasks (lint, format, check)
├── modules/
│   ├── darwin.nix      # macOS system settings, fonts, Homebrew casks
│   ├── home.nix        # Home Manager entry point
│   ├── packages.nix    # CLI tools and yazi config
│   ├── shell.nix       # Zsh, fzf, zoxide, bat, eza
│   ├── terminal.nix    # Ghostty, tmux
│   ├── git.nix         # Git, delta, lazygit, gh
│   ├── zed.nix         # Zed editor config
│   └── claude-code.nix # Claude Code config
└── configs/            # Configs not managed by Nix (nvim, p10k)
```

## CLI Tools

### Shell

| Tool | Description |
|------|-------------|
| **zsh** | Shell with vi-mode, fzf-tab, fast-syntax-highlighting |
| **powerlevel10k** | Prompt theme |
| **fzf** | Fuzzy finder |
| **zoxide** | Smarter `cd` with history |
| **bat** | `cat` with syntax highlighting |
| **eza** | `ls` with icons and git status |

### Files & Navigation

| Tool | Description |
|------|-------------|
| **yazi** | Terminal file manager with previews |
| **fd** | Fast `find` replacement |
| **ripgrep** | Fast `grep` replacement |
| **sd** | Simple `sed` replacement |
| **dust** | `du` with visualization |
| **ouch** | Universal archiver (zip, tar, gz, etc.) |
| **tree** | Directory tree |

### Git

| Tool | Description |
|------|-------------|
| **lazygit** | Git TUI |
| **delta** | Syntax-highlighted diffs with side-by-side view |
| **gh** | GitHub CLI |
| **gh-dash** | PR and issues dashboard |
| **git-lfs** | Large File Storage |

### Terminal

| Tool | Description |
|------|-------------|
| **ghostty** | GPU-accelerated terminal |
| **tmux** | Terminal multiplexer with vim-style navigation |

### Editors

| Tool | Description |
|------|-------------|
| **neovim** | LazyVim config |
| **zed** | GUI editor |
| **cursor** | AI editor |

### DevOps

| Tool | Description |
|------|-------------|
| **lazydocker** | Docker TUI |
| **orbstack** | Docker & Linux VMs for macOS |
| **ansible** | Infrastructure automation |

### Utilities

| Tool | Description |
|------|-------------|
| **jq** / **yq** | JSON/YAML parsers |
| **httpie** | HTTP client |
| **btop** | System monitor |
| **tokei** | Lines of code counter |
| **glow** | Markdown viewer |

### Nix Tooling

| Tool | Description |
|------|-------------|
| **nixd** | Nix LSP |
| **nixpkgs-fmt** | Formatter |
| **statix** | Linter |
| **deadnix** | Dead code finder |

## mise Tasks

Dev tasks defined in `mise.toml`:

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
# or use the shell alias:
rebuild
```

Update all inputs:
```bash
nix flake update
# or:
update
```

Clean up Nix store:
```bash
nix-collect-garbage -d
# or:
cleanup
```

## macOS Settings

Automatically configured:

- **Dock**: auto-hide, no recent apps
- **Finder**: show hidden files, extensions, path bar
- **Keyboard**: fast key repeat, no auto-corrections
- **Security**: Touch ID for sudo
- **Screenshots**: saved to `~/Pictures/Screenshots`
