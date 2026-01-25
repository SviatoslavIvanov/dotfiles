# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History file location
export HISTFILE="$XDG_CACHE_HOME/zsh/history"
# How many commands zsh will load to memory.
export HISTSIZE=100000
# How many commands history will save on file.
export SAVEHIST=100000

# History improvements
setopt AUTO_CD
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_DUPS
setopt HIST_VERIFY
setopt APPENDHISTORY 

if [[ ! -n "$CURSOR_AGENT" ]]; then
  # Custom commands
  source $ZDOTDIR/functions.zsh

  # Personal aliases and commands
  source $ZDOTDIR/personal.zsh

  # Custom aliases
  source $ZDOTDIR/aliases.zsh
fi


# brew installed completions
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
# zsh-completions plugin
FPATH="${ZPLUGDIR}/zsh-completions/src:${FPATH}"
# Custom completions
FPATH="${ZDOTDIR}/completions:${FPATH}"

# zsh-vi-mode
source $ZPLUGDIR/zsh-vi-mode/zsh-vi-mode.plugin.zsh
ZVM_VI_INSERT_ESCAPE_BINDKEY=jj
# The plugin will auto execute this zvm_after_init function
function zvm_after_init() {
    # fzf
    [ -f $XDG_CONFIG_HOME/fzf/fzf.zsh ] && source $XDG_CONFIG_HOME/fzf/fzf.zsh
}

# fast-syntax-highlighting
source $ZPLUGDIR/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
fast-theme XDG:catppuccin-mocha -q

# zsh-auto-suggestions
source $ZPLUGDIR/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-auto-completions
source $ZPLUGDIR/zsh-autocomplete/zsh-autocomplete.plugin.zsh 
zstyle ':autocomplete:*' add-space '*'

# navi
eval "$(navi widget zsh)"

# powerlevel10k
source $ZPLUGDIR/powerlevel10k/powerlevel10k.zsh-theme

# Completions
zstyle '*:compinit' arguments -d "$XDG_CACHE_HOME/zsh/.zcompdump"
# autoload -U compinit; compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"

# To customize prompt, run `p10k configure` or edit ~/.config/p10k/config.zsh.
[[ ! -f $XDG_CONFIG_HOME/p10k/config.zsh ]] || source $XDG_CONFIG_HOME/p10k/config.zsh

# thefuck
eval $(thefuck --alias)


# Shell-GPT integration ZSH v0.2
_sgpt_zsh() {
if [[ -n "$BUFFER" ]]; then
    _sgpt_prev_cmd=$BUFFER
    BUFFER+="⌛"
    zle -I && zle redisplay
    BUFFER=$(sgpt --shell <<< "$_sgpt_prev_cmd" --no-interaction)
    zle end-of-line
fi
}
zle -N _sgpt_zsh
bindkey ^o _sgpt_zsh
# Shell-GPT integration ZSH v0.2

# gh copilot
eval "$(gh copilot alias -- zsh)"

# pnpm
export PNPM_HOME="/Users/ivsv/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# duckdb
export PATH='/Users/ivsv/.duckdb/cli/latest':$PATH

if [[ ! -n "$CURSOR_AGENT" ]]; then
  # zoxide
  eval "$(zoxide init zsh)"
fi

export PATH="$HOME/.opencode/bin":$PATH

eval "$(mise activate zsh)"

ulimit -n 10240
