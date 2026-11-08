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
| **Catppuccin Mocha** | Theme across all apps; fonts and palette live in `theme.nix` |
| **Homebrew** (via nix-homebrew) | GUI apps and casks |
| **mise** | Runtime version manager + task runner |

### Structure

```
.
├── flake.nix           # Entry point, inputs and outputs
├── flake.lock          # Pinned dependency versions
├── mise.toml           # Dev tasks (lint, format, check)
├── modules/
│   ├── system.nix      # macOS settings, security, power, login shell
│   ├── homebrew.nix    # Homebrew casks and formulae
│   ├── home.nix        # Home Manager entry point
│   ├── hygiene.nix     # XDG paths and home-directory audit
│   ├── packages.nix    # CLI tools
│   ├── yazi.nix        # yazi file manager
│   ├── shell.nix       # Zsh, starship, fzf, atuin, zoxide, mise
│   ├── ghostty.nix     # Ghostty terminal
│   ├── tmux.nix        # tmux
│   ├── git.nix         # Git, delta, lazygit, gh
│   ├── aerospace.nix   # AeroSpace workspaces and window rules
│   ├── theme.nix       # Catppuccin, fonts and palette
│   ├── zed.nix         # Zed editor settings
│   ├── agents.nix      # Rules, skills and MCP servers shared by all agents
│   ├── claude-code.nix # Claude Code settings, LSP and statusline
│   ├── codex.nix       # Codex config merge
│   └── pi.nix          # Pi CLI, configuration and extension restore command
└── configs/            # Non-Nix configs (agents, mise, pi)
```

## CLI Tools

### Shell & Navigation

| Tool | Description |
|------|-------------|
| **zsh** | Shell with vi-mode, fzf-tab, fast-syntax-highlighting |
| **starship** | Prompt |
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

Zed is the default external editor (`EDITOR` and `VISUAL` are `zed --wait`, which
Git follows; LazyGit uses its Zed preset). `v` opens Zed; `/usr/bin/nano` remains a manual
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
| `Space a n` / `Cmd Alt Shift C` | New Codex thread |
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

Zed is tuned as a quiet review surface: no autosave, edit predictions or automatic
popups, larger UI and agent fonts than code, and Vim leader bindings; the details
live in [`modules/zed.nix`](modules/zed.nix).

### DevOps & Containers

| Tool | Description |
|------|-------------|
| **orbstack** | Docker & Linux VMs for macOS |
| **lazydocker** | Docker TUI |
| **ansible** | Infrastructure automation (pipelining enabled) |
| **VMware Fusion** | Primary general-purpose VM app (vendor-managed) |
| **utm** | Existing Windows labs and emulation |

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
| **openssh** | Nix OpenSSH with built-in FIDO2 support |
| **coreutils** | GNU core utilities |
| **gnused** | GNU sed |
| **curl** / **wget** | HTTP clients |

### AI Tools

| Tool | Description |
|------|-------------|
| **claude** | Claude desktop app |
| **claude-code** | Claude CLI agent |
| **codex** | OpenAI Codex CLI |
| **pi** | Extensible coding harness; pinned CLI and non-secret config via Nix |

One source in [`modules/agents.nix`](modules/agents.nix) feeds all three agents:

| What | Source | Claude Code | Codex | Pi |
|---|---|---|---|---|
| Rules | [`configs/agents/AGENTS.md`](configs/agents/AGENTS.md) | `~/.claude/CLAUDE.md` | `~/.codex/AGENTS.md` | `~/.pi/agent/AGENTS.md` |
| Skills | `skills` attrset | `~/.claude/skills` | `~/.agents/skills` | `~/.agents/skills` |
| MCP | `programs.mcp.servers` | personal plugin `hm` | `config.toml` | `mcp.json` |

Third-party skills come from pinned flake inputs (`claude-plugins-official`,
`playwright-cli`, `sentry-plugin-claude`); `nix flake update` brings their
changes as a reviewable lock diff. The `playwright-cli` input also builds the
CLI, so the CLI and its skill share one version. Skills keep to the open Agent
Skills frontmatter so every agent can load them. Claude Code also gets a TypeScript LSP from Nix.

Settings files stay writable: Home Manager merges declared keys into them on
activation (`mutableSettings` for Claude Code and Pi, `mkImpureConfigMerger`
for Codex), so `/config`, plugin toggles, project trust and the desktop app's
state survive. `programs.codex` is not used: with `preferXdgDirectories` it
moves `CODEX_HOME` away from `~/.codex`, which the ChatGPT desktop app reads.
The global `bypassPermissions` mode, Codex `danger-full-access` and the
disabled sandbox are intentional; use them only with trusted projects.

Servers needed in one repository live in that repository: `.mcp.json` for
Claude Code, `.pi/mcp.json` as a symlink to it, `.codex/config.toml` for Codex,
and `enabledMcpjsonServers` in `.claude/settings.json`. This repository adds
`mcp-nixos` that way. Work plugins are declared in the private flake, disabled
globally and enabled by the repositories that use them.

Pi configuration lives in [`configs/pi`](configs/pi/README.md), managed by
[`modules/pi.nix`](modules/pi.nix). Credentials, sessions, trust decisions, and
caches remain local. Settings stay writable; Nix restores declared preferences
on activation without replacing Pi's runtime keys. Extension dependencies and
local patches are restored explicitly with `pi-restore-extensions`, not
during activation. Stop Pi before rebuilding/restoring; see the Pi README for
first-migration file collisions, legacy PATH precedence, and offline checks.

### Nix Tooling

| Tool | Description |
|------|-------------|
| **nixd** | Nix LSP |
| **nixfmt** | Official Nix formatter |
| **statix** | Linter |
| **deadnix** | Dead code finder |

## GUI Apps (via Homebrew)

**Productivity:** Raycast, Obsidian, Todoist, Linear

**Browsers:** Google Chrome

**Communication:** Telegram, WhatsApp, Signal, Discord, Zoom

**Media:** Spotify

**Security:** 1Password (+ CLI)

**Gaming:** Steam, Moonlight

**Utilities:** Ice (menu bar), Mac Mouse Fix

**Unmanaged exceptions:** qBittorrent stays installed until upstream ships a
Gatekeeper-compliant build; VMware Fusion uses its vendor installer; VIA
keyboards are configured with the maintained [VIA web app](https://usevia.app/).
Arc stays installed but unmanaged: it is discontinued upstream and its cask is
deprecated. Pages, Numbers and Keynote stay with the App Store. The screen locks
immediately; that is set once in System Settings.

## Fonts

Monaspace Nerd Font, with JetBrains Mono Nerd Font as fallback.

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
mise run pi-check     # Check Pi extension versions
mise run pi-extensions-check # Check installed Pi extensions and critical regressions
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
sudo darwin-rebuild switch --flake "$DOTFILES_DIR" --no-update-lock-file
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
generations and are not reverted by `darwin-rebuild --rollback`. Activation never
upgrades or removes casks; upgrade one explicitly with `brew upgrade --cask <name>`.

The mise config/lock are writable links into `$DOTFILES_DIR` so mise can update
them. Git, rather than Nix generations, is their rollback mechanism.

CLI tools belong to Nix. When migrating an existing Brew installation, build
and activate Nix first, verify command paths, then remove Brew duplicates
without `--ignore-dependencies` or automatic dependency cleanup. Borders stays
with the Brew-managed AeroSpace for now.

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
- **Windows:** one Space across displays and Mission Control grouped by app
  (AeroSpace recommendations), no window open/close animations
- **Finder:** show hidden files, extensions, path bar, status bar
- **Keyboard:** fast key repeat (2/15), no auto-corrections
- **Security:** firewall + stealth mode, Touch ID for sudo (also inside tmux), guest login disabled
- **Login shell:** the Nix zsh
- **Power:** displays sleep after 10 minutes; computer sleep is disabled on AC
  and delayed to 30 minutes on battery
- **Updates:** automatic macOS and App Store updates
- **Screenshots:** saved to `~/Pictures/Screenshots`
