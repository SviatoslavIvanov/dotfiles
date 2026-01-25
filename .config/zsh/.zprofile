export EDITOR="$HOME/bin/nvim-lazyvim"
export VISUAL="$HOME/bin/nvim-lazyvim"

# Disable zsh_sessions
export SHELL_SESSIONS_DISABLE=1

# Added by Toolbox App
export PATH="$PATH:/Users/ivsv/Library/Application Support/JetBrains/Toolbox/scripts"

if [ "$(uname)" = "Darwin" ]; then
  # Mac OS X platform
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
  # GNU/Linux platform
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# bat
export BAT_THEME="Catppuccin-mocha"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# fzf
export FZF_DEFAULT_OPTS=" \
  --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
  --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"


# Created by `pipx` on 2024-02-23 15:57:42
export PATH="$PATH:/Users/ivsv/.local/bin"

export PATH="$PATH:/Users/ivsv/.dotnet/tools"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
