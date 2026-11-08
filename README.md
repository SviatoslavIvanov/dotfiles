# dotfiles

Personal Nix-powered macOS configuration. Terminal-first workflow.

Nix pins the system configuration and CLI tools. Git pins the writable
tool-manager lock file. Homebrew, App Store, vendor-managed apps,
credentials, and application data remain external state and are intentionally
not presented as fully reproducible.

## Prerequisites

1. Install **Nix** with the [Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer).
2. Install and sign in to **1Password**, then enable its CLI integration and
   SSH Agent. The private flake input must be accessible during bootstrap; once
   configured, agenix activation uses a local machine identity and does not
   depend on 1Password login timing.
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
│   ├── hygiene.nix     # XDG paths and home-directory audit
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
| **tree-sitter** | Parser development CLI |
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
| **zed** | Code browsing, Git review, and ACP agents |
| **VS Code** | When you need extensions |

Zed is the default external editor (`EDITOR`, `VISUAL`, and Git use `zed --wait`;
LazyGit uses its Zed preset). `v` opens Zed; `/usr/bin/nano` remains a manual
terminal fallback. VS Code is retained as a backup, without Neovim integration.

Zed's layout keeps files/Git/outline on the left, the agent and Threads Sidebar on the
right, and terminals below the editor. The Threads Sidebar does not automatically
open when adding a folder to an existing window. Settings live in
[`modules/zed.nix`](modules/zed.nix); Home Manager generates read-only JSON files.

| Zed shortcut | Action |
|--------------|--------|
| `Space e` (Vim normal mode) | Focus the file tree or return to the editor |
| `Cmd B` / `Cmd Alt B` | Toggle the left / right dock |
| `Space a a` | Focus the agent |
| `Space a d` | Review the active agent's changes (where supported) |
| `Space a n` / `Space a o` / `Cmd Alt Shift C` | New Codex thread |
| `Space a l` / `Cmd Alt J` | Toggle the Threads Sidebar |
| `Space a s` | Add selection to the current agent thread |
| `Space g d` | Review uncommitted changes against HEAD |
| `Space g c` | Choose a branch to compare the task's changes against |
| `] h` / `[ h` | Next / previous changed hunk |
| `Space o` | Focus the outline panel |
| `K` (Vim normal mode) / `Cmd K`, `Cmd I` | Show documentation on demand |
| `Space b p` | Pin or unpin the current tab |
| `Enter` / `o` in the file tree | Preview the selected file |
| `Shift Enter` in the file tree | Open the selected file permanently |
| `Ctrl /` | Toggle the bottom dock |

Codex uses the [ACP Registry](https://zed.dev/docs/ai/external-agents), with agent
ID `codex-acp`. Zed installs its runtime when starting a Codex thread; complete the
agent's sign-in flow if prompted. Model and authentication settings belong to
Codex. Built-in agent model overrides and the inline-assistant shortcut are
removed; new-thread leader bindings launch Codex directly. The shared Agent
Panel stays enabled because disabling all AI also disables external ACP agents.

Sticky scope headers, smart-case search, and inline agent edit review are enabled.
The quiet UI hides account/onboarding controls, collaboration and search buttons,
inline diagnostic text, inlay hints, diagnostic badges, tab icons, and quick-action
menus. Breadcrumbs, project/branch identity, Git markers, and review controls stay
visible. Inlay hints remain available on demand with `Space u i`. The commit
editor starts collapsed. Catppuccin Mocha keeps its peach accent and syntax colors,
with matching panel backgrounds, neutral separators, a subtle active-line tint,
and a non-blinking cursor. Stock Zed icons keep the file tree quiet.

The UI uses Zed's proportional font at 26 px; code uses Monaspice at 22 px with
1.4 line height. Agent responses use 28 px and its input/code font uses 24 px.
Navigation and agent prose are enlarged independently for comfortable reading
on the external monitor, without increasing the editor's code size.
Automatic documentation popovers are disabled; request documentation with `K`
in Vim normal mode or `Cmd K`, `Cmd I`.
Navigation panels default to 280 px, and the agent defaults to a fixed 560 px.
Existing windows may retain manually resized docks; these are reset defaults,
not enforced proportions. The right dock can be hidden for wide diff reviews.

File finder and file-tree navigation use preview tabs; pin a tab or open it
permanently to keep it. Reference multibuffers remain permanent while browsing
their source files. The tree no longer follows every code-navigation jump;
`Space f E` reveals the current file explicitly. Branch comparison opens a
separate view without changing the normal HEAD-based diff. Outline retains
symbol and search-match details instead of globally hiding them in multibuffers.

The review-oriented defaults disable autosave, AI edit predictions, automatic
completion menus, and signature popups; use absolute line numbers; display Git changes as a file
tree; and show blame/commit summaries in the status bar. Split diffs automatically
fall back to unified diffs below 100 em of editor width. Buffers remain editable;
this is not a read-only mode. Source/tooling folders such as `.husky`,
`.storybook`, `.vscode`, and `bin` remain searchable unless ignored by the project.

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
mise run lock-check   # Validate mise lock file
mise run secret-check # Scan the tree and history for secrets
mise run lint         # Run all checks
```

## Usage

Apply changes (commit them first; `rebuild` refuses a dirty tree unless
`REBUILD_DIRTY=1` is set):
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

The mise config/lock are writable links into `$DOTFILES_DIR` so mise can update
them. Git, rather than Nix generations, is their rollback mechanism.

Collect unreachable Nix store paths without deleting profile generations:
```bash
nix-collect-garbage
```

Audit top-level home-directory entries without changing or deleting anything:

```bash
home-audit           # fast inventory
home-audit --sizes   # include recursive disk usage (slower)
```

Node, Python, and PostgreSQL histories, npm and Ansible caches, Wget state, and
the Ansible config use explicit XDG paths. Existing legacy files and stateful
SDK homes are intentionally left in place for manual review.

## macOS Defaults

Automatically configured:

- **Dock:** auto-hide, no recent apps, stable spaces order
- **Finder:** show hidden files, extensions, path bar, status bar
- **Keyboard:** fast key repeat (2/15), no auto-corrections
- **Security:** firewall + stealth mode, Touch ID for sudo, guest login disabled, immediate lock
- **Power:** displays sleep after 10 minutes; computer sleep is disabled on AC
  and delayed to 30 minutes on battery
- **Updates:** automatic macOS and App Store updates
- **Screenshots:** saved to `~/Pictures/Screenshots`
