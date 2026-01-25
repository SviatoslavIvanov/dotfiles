# Custom paths
export ZPLUGDIR="$ZDOTDIR/plugins"

# zsh-autocomplete setting for ubuntu
skip_global_compinit=1

export POWERLEVEL9K_CONFIG_FILE=$XDG_CONFIG_HOME/p10k/config.zsh

# less history
export LESSHISTFILE="$XDG_CACHE_HOME/less/.lesshst"

# tldr
export TEALDEER_CONFIG_DIR="$XDG_CONFIG_HOME/tealdeer"

# pypoetry
export POETRY_CONFIG_DIR="$XDG_CONFIG_HOME/pypoetry"

# 1passwrd ssh agent

if [ "$(uname)" = "Darwin" ]; then
  # Mac OS X platform
  export SSH_AUTH_SOCK=~/.1password/agent.sock
elif [ "$(expr substr $(uname -s) 1 5)" = "Linux" ]; then
  # GNU/Linux platform
fi

# wsl
if uname -r |grep -q 'Microsoft' ; then
    alias ssh='ssh.exe'
    alias ssh-add='ssh-add.exe'
    alias ollama='ollama.exe'
    if [ -n "$SSH_CONNECTION" ]; then
      /mnt/c/Windows/System32/wsl.exe
    fi
fi

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"

# Expiremental, setting language to english manually
# LANG=en_US
