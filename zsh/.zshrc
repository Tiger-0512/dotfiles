export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"


#-------------------- zinit --------------------#
### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/z-a-rust \
    zdharma-continuum/z-a-patch-dl \
    zdharma-continuum/z-a-as-monitor \
    zdharma-continuum/z-a-bin-gem-node

### End of Zinit's installer chunk


#-------------------- plugin --------------------#
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


#-------------------- theme --------------------#
eval "$(starship init zsh)"


#-------------------- lf --------------------#
# Set icons
source ~/.config/lf/icons
export EDITOR="nvim"
export VISUAL="nvim"
# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'


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


#-------------------- asdf --------------------#
. /usr/local/opt/asdf/libexec/asdf.sh
export ASDF_PATH=$HOME/.asdf
# Conflict with homebrew
alias brew="PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin brew"


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


# export PATH=$PATH:$HOME/noevide/target/release/neovide
# alias neovide='open -a Neovide.app .'
alias neovide=~/neovide/target/release/neovide


##-------------------- nnn --------------------#
#export LC_COLLATE="C"
#export NNN_TMPFILE="/tmp/nnn"
#export NNN_OPTS="H"
#export NNN_FIFO="/tmp/nnn.fifo"
#export NNN_PLUG="p:preview-tui"
#export VISUAL="nvim"
#export EDITOR="nvim"

## Theme
## BLK="0B" CHR="0B" DIR="04" EXE="06" REG="00" HARDLINK="06" SYMLINK="06" MISSING="00" ORPHAN="09" FIFO="06" SOCK="0B" OTHER="06"
## export NNN_FCOLORS="$BLK$CHR$DIR$EXE$REG$HARDLINK$SYMLINK$MISSING$ORPHAN$FIFO$SOCK$OTHER"
#export NNN_FCOLORS='c1e2272e006033f7c6d6abc4'

## Enable cd on quit with n
#n()
#{
#    nnn "$@"

#    if [ -f $NNN_TMPFILE ]; then
#        . $NNN_TMPFILE
#        rm $NNN_TMPFILE
#    fi
#}
## Check FIFO
#NNN_FIFO=${NNN_FIFO:-$1}
#if [ ! -r "$NNN_FIFO" ]; then
#    # echo "Unable to open \$NNN_FIFO='$NNN_FIFO'" | less
#    # exit 2
#    mkdir /tmp/nnn.fifo
#fi
