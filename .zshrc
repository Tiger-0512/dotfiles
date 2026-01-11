
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# # zellij内かどうかを判定する関数
# # 注意: .zshrc読み込み時点では$ZELLIJ環境変数が未設定のため、プロセスツリーで検出
# _is_inside_zellij() {
#   # プロセスツリー全体でzellijを検索（最優先）
#   local pid=$$
#   while [[ $pid -gt 1 ]]; do
#     local pname=$(ps -o comm= -p $pid 2>/dev/null)
#     if [[ "$pname" == *"zellij"* ]]; then
#       return 0
#     fi
#     pid=$(ps -o ppid= -p $pid 2>/dev/null | tr -d ' ')
#     if [[ -z "$pid" ]]; then
#       break
#     fi
#   done
# 
#   # フォールバック: $ZELLIJ環境変数をチェック
#   if [[ -n "$ZELLIJ" ]]; then
#     return 0
#   fi
# 
#   return 1
# }

# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

export PATH=/usr/local/bin:$PATH
export PATH="/usr/local/sbin:$PATH"

export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"


#-------------------- Sheldon --------------------#
cache_dir=${XDG_CACHE_HOME:-$HOME/.cache}
sheldon_cache="$cache_dir/sheldon.zsh"
sheldon_toml="$HOME/.config/sheldon/plugins.toml"
# zellij内ではキャッシュ再生成をスキップ（ハング防止）
if [[ ! -r "$sheldon_cache" ]] || { [[ "$sheldon_toml" -nt "$sheldon_cache" ]] && ! _is_inside_zellij; }; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml


#-------------------- Theme --------------------#
# Starship の初期化をキャッシュ
_starship_cache="${XDG_CACHE_HOME:-$HOME/.cache}/starship.zsh"
# zellij内ではキャッシュ再生成をスキップ（ハング防止）
if [[ ! -f "$_starship_cache" ]] || { [[ /opt/homebrew/bin/starship -nt "$_starship_cache" ]] && ! _is_inside_zellij; }; then
  starship init zsh > "$_starship_cache"
fi
source "$_starship_cache"
unset _starship_cache


#-------------------- tmux --------------------#
# tmux auto-start disabled
# if [[ -z "$TMUX" && ! -z "$PS1" && $TERM_PROGRAM != "vscode" && $TERM_PROGRAM != "kiro" ]]; then
#     # get the IDs
#     ID="`tmux list-sessions`"
#     if [[ -z "$ID" ]]; then
#         tmux new-session
#     fi
#     create_new_session="Create New Session"
#     ID="$ID\n${create_new_session}:"
#     ID="`echo $ID | fzf | cut -d: -f1`"
#     if [[ "$ID" = "${create_new_session}" ]]; then
#         tmux new-session
#     elif [[ -n "$ID" ]]; then
#         tmux attach-session -t "$ID"
#     else
#         :  # Start terminal normally
#     fi
# fi


#-------------------- zellij --------------------#
# 自動起動を一時的に無効化（コメントアウトを外すことで再度有効化可能）
# if ! _is_inside_zellij && [[ ! -z "$PS1" ]] && [[ $TERM_PROGRAM != "vscode" ]] && [[ $TERM_PROGRAM != "kiro" ]]; then
#     # get the session list
#     SESSIONS=$(zellij list-sessions -n 2>/dev/null)
#
#     if [[ -z "$SESSIONS" ]]; then
#         # No existing sessions, create a new one
#         zellij
#     else
#         # Sessions exist, let user choose
#         create_new_session="Create New Session"
#         SESSIONS="$SESSIONS\n${create_new_session}"
#         SELECTED=$(echo $SESSIONS | fzf --prompt="Select Zellij Session: " --height=~50% --layout=reverse --border --exit-0)
#
#         if [[ "$SELECTED" = "${create_new_session}" ]]; then
#             # Create new session with random name
#             zellij
#         elif [[ -n "$SELECTED" ]]; then
#             # Extract session name (first word) from the selected line
#             SESSION_NAME=$(echo "$SELECTED" | awk '{print $1}')
#             zellij attach "$SESSION_NAME"
#         else
#             :  # Start terminal normally (user pressed ESC)
#         fi
#     fi
# fi


#-------------------- asdf --------------------#
# asdf を遅延ロード（初回実行時のみ読み込み）
export ASDF_PATH=$HOME/.asdf
export PATH="/Users/taigamat/.asdf/shims:$PATH"

# asdf コマンドの遅延ロードラッパー
asdf() {
  unfunction asdf
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  asdf "$@"
}

# Solve conflict with homebrew
# alias brew="PATH=/usr/local/bin:/usr/bin:/bin:/user/local/sbin:/usr/sbin:/sbin brew"


# #-------------------- LF --------------------#
# # Set icons
# source ~/.config/lf/icons
# export EDITOR="nvim"
# export VISUAL="nvim"
# # Use lf to switch directories and bind it to ctrl-f
# lfcd () {
#     tmp="$(mktemp)"
#     lf -last-dir-path="$tmp" "$@"
#     if [ -f "$tmp" ]; then
#         dir="$(cat "$tmp")"
#         rm -f "$tmp"
#         [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
#     fi
# }
# bindkey -s '^f' 'lfcd\n'

#-------------------- zoxide --------------------#
eval "$(zoxide init zsh)"

function fzf-cdr() {
    local selected_dir=$(zoxide query -l | fzf --prompt="Where you wanna go?> " --tac --preview 'eza --tree --level=2 {}')
    if [ -n "$selected_dir" ]; then
        BUFFER="cd ${selected_dir}"
        zle accept-line
        zle clear-screen
     else
        zle redisplay
    fi
}

zle -N fzf-cdr

bindkey '^g^f' fzf-cdr

#-------------------- yazi --------------------#
export EDITOR="nvim"
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
bindkey -s '^f' 'y\n'

#-------------------- GitUI --------------------#
# bindkey -s '^g' 'gitui\n'

#-------------------- lazygit --------------------#
export XDG_CONFIG_HOME="$HOME/.config"
bindkey -s '^g^g' 'lazygit\n'

#-------------------- fzf --------------------#
export FZF_DEFAULT_OPTS="--height 50% --layout=reverse --border --inline-info --preview 'head -100 {}'"


#-------------------- Poetry --------------------#
export PATH="$HOME/.local/bin:$PATH"


#-------------------- Solana --------------------#
export PATH="/Users/taigamat/.local/share/solana/install/active_release/bin:$PATH"


#-------------------- ash --------------------#
export PATH="/Users/taigamat/.local/share/automated-security-helper:$PATH"

#-------------------- direnv --------------------#
eval "$(direnv hook zsh)"

# #-------------------- finch --------------------#
# alias docker='finch'

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# Cline settings to use shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

export PATH=$HOME/.toolbox/bin:$PATH

alias cat='bat'

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
