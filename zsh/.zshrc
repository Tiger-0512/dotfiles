export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"


#-------------------- nnn --------------------#
export LC_COLLATE="C"
export NNN_TMPFILE="/tmp/nnn"
export NNN_OPTS="H"
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PLUG="p:preview-tui"
export VISUAL="nvim"
export EDITOR="nvim"

# Theme
# BLK="0B" CHR="0B" DIR="04" EXE="06" REG="00" HARDLINK="06" SYMLINK="06" MISSING="00" ORPHAN="09" FIFO="06" SOCK="0B" OTHER="06"
# export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'

# Enable cd on quit with n
n()
{
    nnn "$@"

    if [ -f $NNN_TMPFILE ]; then
        . $NNN_TMPFILE
        rm $NNN_TMPFILE
    fi
}
# Check FIFO
NNN_FIFO=${NNN_FIFO:-$1}
if [ ! -r "$NNN_FIFO" ]; then
    # echo "Unable to open \$NNN_FIFO='$NNN_FIFO'" | less
    # exit 2
    mkdir /tmp/nnn.fifo
fi


#-------------------- tmux --------------------#
if [[ ! -n $TMUX ]]; then
  # get the IDs
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo $ID | fzf | cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$ID" ]]; then
    tmux attach-session -t "$ID"
  else
    :  # Start terminal normally
  fi
fi


#-------------------- vim --------------------#
bindkey -v
# bindkey -M vicmd "^I" beginning-of-line
# bindkey -M vicmd "^A" end-of-line

# Show current mode
function zle-keymap-select {
    RPS1="${${KEYMAP/vicmd/$VIM_NORMAL}/(main|viins)/$VIM_INSERT}"
    RPS2=$RPS1
    zle reset-prompt
}
zle -N zle-keymap-select


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
