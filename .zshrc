
# eval キャッシュヘルパー (zcache) を先に読み込む。
# 以降の kiro-cli / starship / zoxide / direnv / mise 初期化で使う。
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/cache-eval.zsh" ]] \
  && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/cache-eval.zsh"

# Kiro CLI pre block. Keep at the top of this file.
# 本来は下記 vendor ファイルを source するが、その中身は
#   eval "$(kiro-cli init zsh pre --rcfile zshrc)"
# で毎回 subprocess を起動し ~35ms 掛かる。出力を zcache で固定化する。
# 注意: kiro-cli の再インストール時に本ブロックが上書き・再追加されることがある
# (git log 参照)。その場合は chezmoi apply で本ファイルの内容に戻す。
if (( $+commands[kiro-cli] )) && (( $+functions[zcache] )); then
  # 出力に生成時の zsh 実体 path (Q_SHELL) が焼き込まれるため zsh も stamp に含める。
  # :A は symlink を解決する zsh の modifier (readlink 相当、subprocess 不要)。
  _zsh_real="${${commands[zsh]:-$SHELL}:A}"
  # zcache_gen_kiro は生成物の mkdir に存在チェックを足すフィルタ
  # (毎起動の fork を省く。cache-eval.zsh 参照)。
  zcache -s "$_zsh_real" kiro-pre kiro-cli zcache_gen_kiro kiro-cli init zsh pre --rcfile zshrc
else
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
fi



# path 配列に重複エントリを持たせない (PATH も同期して uniq される)。
# 以降の 'path=(new $path)' や 'export PATH=X:$PATH' が繰り返し評価されても
# 同じディレクトリが複数回登録されない。
typeset -U path PATH

# fpath も同様に重複を排除する。こちらは実害があって入れている:
# `brew shellenv` の出力は FPATH を **export** するため、子の zsh がそれを
# 継承した上で /etc/zshenv が $NIX_PROFILES 分 (12 entries) を無条件に
# 再 prepend する。結果 zsh の入れ子ごとに fpath が 14 → 27 → 40 と増える。
# 実際のターミナルは kiro-cli の figterm 経由で zsh が 2 段になるため、
# 素の 14 ではなく 27 entries で動いていた (実測)。
# compinit は fpath の全 entry を走査するので重複分がそのまま二重走査になる。
typeset -U fpath FPATH

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
if [[ ! -r "$sheldon_cache" ]] || [[ "$sheldon_toml" -nt "$sheldon_cache" ]]; then
  mkdir -p $cache_dir
  sheldon source > $sheldon_cache
fi
source "$sheldon_cache"
unset cache_dir sheldon_cache sheldon_toml


#-------------------- Theme --------------------#
# Starship の初期化をキャッシュ (zcache に共通化。判定ロジックは cache-eval.zsh 参照)
# zcache_gen_starship は PROMPT2 の command substitution を生成時に展開して
# literal に置き換えるフィルタ (毎起動の fork ~14ms を省く。cache-eval.zsh 参照)。
#
# -f で starship.toml の内容を stamp に含める。焼き込む PROMPT2 の値
# (starship prompt --continuation) は config を読んで決まるため、
# binary だけを stamp にしていると continuation_prompt を設定しても反映されない。
zcache -f "${STARSHIP_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/starship.toml}" \
  starship starship zcache_gen_starship starship init zsh


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
zcache zoxide zoxide zoxide init zsh

# zoxide init の出力には
#   [[ "${+functions[compdef]}" -ne 0 ]] && compdef __zoxide_z_complete z
# が含まれるが、compdef を定義する compinit は sheldon 側で zsh-defer される
# ため、ここでは未定義でガードに弾かれる (z のタブ補完が黙って無効になる)。
# /etc/zshrc が eager に compinit していた頃は間に合っていた経路。
# zsh-defer は FIFO なので compinit の後に登録し直せばよい。
# -mpr は prompt に無関係なタスクで precmd 一式 (~50ms) が走るのを止める
# (理由は ~/.config/sheldon/plugins.toml の [templates] コメント参照)。
if (( $+functions[zsh-defer] )) && (( $+functions[__zoxide_z_complete] )); then
  zsh-defer -mpr -c 'compdef __zoxide_z_complete z'
fi

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
zcache direnv direnv direnv hook zsh

# #-------------------- finch --------------------#
# alias docker='finch'

#-------------------- oxker --------------------#
alias oxker="oxker --host \"$HOME/.config/colima/default/docker.sock\""

#-------------------- bat --------------------#
alias cat='bat'

#-------------------- WezTerm shell integration --------------------#
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
  __wezterm_set_user_var() {
    printf "\033]1337;SetUserVar=%s=%s\007" "$1" "$(echo -n "$2" | base64)"
  }
  __wezterm_preexec() {
    __wezterm_set_user_var WEZTERM_CMD "${1%% *}"
    printf "\033]2;%s\007" "${1%% *}"
  }
  __wezterm_precmd() {
    __wezterm_set_user_var WEZTERM_CMD ""
    printf "\033]2;%s\007" "zsh"
  }
  autoload -U add-zsh-hook
  add-zsh-hook preexec __wezterm_preexec
  add-zsh-hook precmd __wezterm_precmd
fi

export PATH=$HOME/.toolbox/bin:$PATH

# Added by AIM CLI
export PATH="$HOME/.aim/mcp-servers:$PATH"

# Q-SPEC Kit
export PATH="$HOME/.q-spec/bin:$PATH"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"

# Cline settings to use shell integration
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"



# -----------------------------------------------------------------
# Nix を PATH の先頭に持ってくる。
# ~/.zprofile で eval "$(brew shellenv)" が走った後に .zshrc が読まれるため、
# ここで再 prepend しないと Homebrew が優先されてしまう。
# ディレクトリが存在する時だけ動くので Nix 未導入マシンでも安全。
# -----------------------------------------------------------------
if [ -d /run/current-system/sw/bin ]; then
    path=(/run/current-system/sw/bin $path)
    export PATH
fi

if [ -d "$HOME/.nix-profile/bin" ]; then
    path=("$HOME/.nix-profile/bin" $path)
    export PATH
fi

# nix-darwin + home-manager (useUserPackages = true) 下では
# home.packages が /etc/profiles/per-user/<USER>/bin に配置される。
# shell の PATH に自動では入らないのでここで prepend する。
if [ -d "/etc/profiles/per-user/$USER/bin" ]; then
    path=("/etc/profiles/per-user/$USER/bin" $path)
    export PATH
fi

# mise: 言語ランタイム version 管理
# Nix PATH の後で activate する必要がある (mise 本体を PATH から解決するため)
#
# activate の出力は読み込み時に `mise hook-env -s zsh` を fork するので
# ~19ms 掛かる (キャッシュしても消えない: fork は生成物の中身)。
# prompt 表示後に回す。最初のコマンド入力までには activate 済みになる。
#
# ただし zsh-defer は zle が idle になった時に走るので、`zsh -i -c '...'`
# では遅延タスクが一度も実行されない。GUI アプリ / launchd / VS Code の task
# などがこの形で node や python を呼ぶため、そこでは eager に activate する。
# -c の判別は zsh が設定する $ZSH_EXECUTION_STRING で行う。
#
# ここは他の遅延タスクと違い -mpr を付けない。activate は PATH を書き換えて
# node / python の version を変えるので、starship が prompt に出している
# 言語 version を 1 度だけ描き直させたい (precmd + reset-prompt が必要)。
if (( $+functions[zsh-defer] )) && [[ -z "$ZSH_EXECUTION_STRING" ]]; then
  zsh-defer -c 'zcache mise mise mise activate zsh'
else
  zcache mise mise mise activate zsh
fi

# nix-darwin 適用の shortcut。
# --impure は chezmoi-internal/darwin-internal.nix を conditional import するため。
# flake の pure evaluation では source tree 外のファイルに pathExists が false を
# 返すので、impure モードで明示的にファイル確認を許可する必要がある。
alias darwin-switch='sudo USER=$USER darwin-rebuild switch --flake "$HOME/.local/share/chezmoi/nix-config#default" --impure'

#-------------------- Herdr --------------------#
# ローカルの対話型 terminal を開いた時に session picker を表示する。
# Herdr pane 内の shell、SSH、他の multiplexer、IDE 内 terminal、
# `zsh -i -c` では起動しない。必要な時は HERDR_DISABLE_AUTO_ATTACH=1 で無効化する。
if [[ -o interactive && -t 0 && -t 1
      && -z "${HERDR_ENV:-}"
      && -z "${HERDR_DISABLE_AUTO_ATTACH:-}"
      && -z "${SSH_CONNECTION:-}"
      && -z "${TMUX:-}"
      && -z "${ZELLIJ:-}"
      && -z "${ZSH_EXECUTION_STRING:-}"
      && "$TERM_PROGRAM" != "vscode"
      && "$TERM_PROGRAM" != "kiro" ]] \
    && (( $+commands[herdr] )); then
  _herdr_select_session() {
    # jq / fzf が無い環境では従来どおり default session へ接続する。
    if (( ! $+commands[jq] || ! $+commands[fzf] )); then
      command herdr
      return
    fi

    local sessions_json session_rows selected session_name new_session_name
    sessions_json="$(command herdr session list --json 2>/dev/null)" || {
      command herdr
      return
    }

    session_rows="$(
      print -rn -- "$sessions_json" |
        command jq -r '
          .sessions[] |
          [
            .name,
            (
              .name
              + (if .default then " (default)" else "" end)
              + " [" + (if .running then "running" else "stopped" end) + "]"
            )
          ] |
          @tsv
        '
    )"

    selected="$(
      {
        printf '\tCreate New Session\n'
        [[ -n "$session_rows" ]] && print -r -- "$session_rows"
      } |
        command fzf \
          --delimiter=$'\t' \
          --with-nth=2 \
          --prompt='Herdr session: ' \
          --height='~50%' \
          --layout=reverse \
          --border \
          --exit-0
    )"

    # Esc なら Herdr を起動せず、現在の shell をそのまま使う。
    [[ -z "$selected" ]] && return

    session_name="${selected%%$'\t'*}"
    if [[ -n "$session_name" ]]; then
      command herdr session attach "$session_name"
      return
    fi

    vared -p 'New Herdr session name: ' -c new_session_name
    [[ -n "$new_session_name" ]] &&
      command herdr session attach "$new_session_name"
  }

  _herdr_select_session
  unfunction _herdr_select_session
fi

# Kiro CLI post block. Keep at the bottom of this file.
# pre ブロックと同様に zcache で subprocess 起動 (~35ms) を省く。
if (( $+commands[kiro-cli] )) && (( $+functions[zcache] )); then
  zcache -s "$_zsh_real" kiro-post kiro-cli kiro-cli init zsh post --rcfile zshrc
  unset _zsh_real
else
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
fi
