# shellcheck shell=bash
#-------------------- eval キャッシュ共通ヘルパー --------------------#
# `eval "$(foo init zsh)"` 形式の初期化を毎回 subprocess で実行すると
# 1 コマンドあたり 10〜70ms 掛かる。出力をファイルにキャッシュして
# source するだけにすれば subprocess 起動を丸ごと省ける。
#
# キャッシュの invalidation はバイナリの「実体 path + version」で判定する。
# mtime 比較を使わない理由: Nix store 内のファイル mtime は 1970 に固定
# されており、更新を検出できない。実体 path には Nix の hash が含まれる
# ため、パッケージ更新時に必ず文字列が変わる。
#
# 使い方:
#   zcache [-s <追加 stamp 文字列>] <name> <binary> <生成コマンド...>
#
# 例:
#   zcache zoxide zoxide zoxide init zsh
#
# -s は生成物が <binary> 以外の要素にも依存する場合に使う。
# 例: kiro-cli init の出力には生成時の zsh 実体 path が Q_SHELL として
# 焼き込まれる。zsh だけが更新されると古い Nix store path が残り、
# GC 後に figterm の起動が壊れる。-s で zsh の path も判定材料に含める。
#
# <binary> が PATH に無い場合は何もしない (未導入マシンでも安全)。

: ${ZCACHE_DIR:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init}

zcache() {
  local extra=""
  if [[ "$1" == "-s" ]]; then
    extra="$2"
    shift 2
  fi

  local name="$1" bin="$2"
  shift 2

  # 絶対 path 指定 (例: /opt/homebrew/bin/brew) と PATH 上のコマンド名の両方を許す。
  # $commands は zsh の連想配列で、command -v の subprocess/fork を伴わない。
  local bin_path
  if [[ "$bin" == /* ]]; then
    [[ -x "$bin" ]] || return 0
    bin_path="$bin"
  else
    bin_path="${commands[$bin]}"
    [[ -n "$bin_path" ]] || return 0
  fi

  local cache="$ZCACHE_DIR/$name.zsh"
  local stamp="$ZCACHE_DIR/$name.stamp"

  # 実体 path を stamp とする。:A は symlink を解決する zsh の modifier
  # (readlink 相当だが subprocess を起動しない)。
  local real="${bin_path:A}"
  [[ -n "$real" ]] || real="$bin_path"
  [[ -n "$extra" ]] && real="$real:$extra"

  local prev=""
  [[ -r "$stamp" ]] && prev=$(<"$stamp")

  if [[ ! -s "$cache" || "$prev" != "$real" ]]; then
    [[ -d "$ZCACHE_DIR" ]] || mkdir -p "$ZCACHE_DIR"
    # 生成失敗時に壊れたキャッシュを残さないよう temp 経由で書く。
    local tmp="$cache.$$"
    if "$@" > "$tmp" 2>/dev/null && [[ -s "$tmp" ]] && zsh -n "$tmp" 2>/dev/null; then
      mv -f "$tmp" "$cache"
      print -r -- "$real" > "$stamp"
    else
      # 生成に失敗した、または出力が構文的に不正だった。
      #
      # 構文検証 (zsh -n) が必要な理由: kiro-cli は一度きりの移行通知などを
      # 出力に混ぜることがあり、その中に zsh として不正な記述
      # (単一引用符内の \' 等) が含まれる場合がある。vendor 経路なら
      # 次回起動時に消えるが、キャッシュすると壊れた出力が恒久化して
      # 毎回 parse error を出し続ける。壊れたものは掴まない。
      rm -f "$tmp"
      # stamp も消して次回起動で再生成を試みる (エラーを固定しない)。
      rm -f "$stamp"
      # この回は subprocess 実行に fallback する。
      eval "$("$@" 2>/dev/null)"
      return 0
    fi
  fi

  source "$cache"
}
