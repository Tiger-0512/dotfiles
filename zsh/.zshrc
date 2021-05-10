export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"


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
# zsh theme
zinit light denysdovhan/spaceship-prompt

# zinit ice wait'0' lucid blockf
# zinit light zsh-users/zsh-completions

zinit ice wait'0' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0' lucid
zinit light zsh-users/zsh-syntax-highlighting


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


#-------------------- golang --------------------#
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin


#-------------------- flutter --------------------#
export PATH=$PATH:$HOME/development/flutter/bin

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools