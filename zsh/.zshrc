export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"


#-------------------- vim --------------------#
bindkey -v
bindkey -M vicmd "^I" beginning-of-line
bindkey -M vicmd "^A" end-of-line

# Show current mode
function zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/$VIM_NORMAL}/(main|viins)/$VIM_INSERT}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-keymap-select


#-------------------- alias --------------------#
alias gc-b=‘git checkout -b’
alias ga=‘git add‘
alias gc-m=‘git commit -m’
alias gp=‘git push’


#-------------------- zinit --------------------#
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk

#-------------------- plugin --------------------#
# Zsh theme
zinit light denysdovhan/spaceship-prompt

# Syntax highlight
zinit light zsh-users/zsh-syntax-highlighting

# Add vi visual mode
zinit light b4b4r07/zsh-vimode-visual

# zinit ice wait'0' lucid blockf
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0' lucid blockf
zinit light zsh-users/zsh-completions
autoload -Uz compinit && compinit -u
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:default' menu select=1


#-------------------- python --------------------#
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/tiger/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/tiger/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/tiger/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/tiger/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# For my macbook
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup


#-------------------- Volta --------------------#
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"


#-------------------- golang --------------------#
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin


#-------------------- flutter --------------------#
export PATH=$PATH:$HOME/development/flutter/bin


#-------------------- gcloud sdk --------------------#
# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then . $HOME/google-cloud-sdk/path.zsh.inc; fi
# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then . $HOME/google-cloud-sdk/completion.zsh.inc; fi


export PATH=$PATH:$HOME/neovide/target/release
