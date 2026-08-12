
# eval キャッシュヘルパー (zcache) を先に読み込む。
# .zprofile は login shell でのみ読まれ、.zshrc より前に走る。
[[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/cache-eval.zsh" ]] \
  && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/cache-eval.zsh"

# Kiro CLI pre block. Keep at the top of this file.
# vendor ファイルの中身は eval "$(kiro-cli init zsh pre --rcfile zprofile)" で
# 毎回 subprocess を起動する (~25ms)。zcache で固定化する。
if (( $+commands[kiro-cli] )) && (( $+functions[zcache] )); then
  # 出力に生成時の zsh 実体 path (Q_SHELL) が焼き込まれるため zsh も stamp に含める。
  # :A は symlink を解決する zsh の modifier (readlink 相当、subprocess 不要)。
  _zsh_real="${${commands[zsh]:-$SHELL}:A}"
  # zcache_gen_kiro は生成物の mkdir に存在チェックを足すフィルタ
  # (毎起動の fork を省く。cache-eval.zsh 参照)。
  zcache -s "$_zsh_real" kiro-zprofile-pre kiro-cli zcache_gen_kiro kiro-cli init zsh pre --rcfile zprofile
else
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"
fi


# Homebrew の環境変数設定をキャッシュ (毎回だと ~65ms)。
# brew が無いマシン (Nix 専用) では zcache が何もしないので安全。
zcache brew /opt/homebrew/bin/brew /opt/homebrew/bin/brew shellenv zsh


# Kiro CLI post block. Keep at the bottom of this file.
if (( $+commands[kiro-cli] )) && (( $+functions[zcache] )); then
  zcache -s "$_zsh_real" kiro-zprofile-post kiro-cli kiro-cli init zsh post --rcfile zprofile
  unset _zsh_real
else
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
fi
