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
  # 生成コマンド自体も stamp に含める。フィルタ (zcache_gen_*) を挟んだり
  # 引数を変えたときにキャッシュが自動で作り直される。
  # これが無いとバイナリが同じ限り古い生成物を掴み続ける。
  real="$real:$*"

  # 生成コマンドが shell function ならその定義内容も含める。
  # フィルタの実装だけを直した場合は $* が変わらないため、これが無いと
  # 古い生成物を掴み続ける (実際に踏んだ)。
  # 改行を空白に潰して 1 行に保つ ($(<file) の末尾改行剥がしと食い違わせない)。
  if (( $+functions[$1] )); then
    real="$real:${functions[$1]//$'\n'/ }"
  fi

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

#-------------------- 生成物から起動時 fork を除くフィルタ --------------------#
# zcache は subprocess の「起動」は省けるが、生成物の中に書かれた
# `$(...)` は source する度に fork される。実測ではここが残りのコストの
# 大半だった (mise ~19ms / starship ~14ms / kiro-cli mkdir ~4ms x2)。
#
# 以下は zcache の <生成コマンド> 位置に挟む wrapper。
# フィルタが走るのはキャッシュ生成時 (= バイナリ更新時) だけなので、
# 変換コスト自体は起動パスに乗らない。
#
# 上流の出力形式が変わってマッチしなくなっても、元の行がそのまま残る
# だけなので壊れない (省いたはずの fork が復活するのみ)。

# kiro-cli init: `mkdir -p "${HOME}/.local/bin"` に存在チェックを足す。
# ~/.local/bin は初回に作られたら以後ずっと存在するが、この行は無条件に
# fork する。pre ブロックは .zprofile と .zshrc の 2 箇所で走るので 2 倍効く。
zcache_gen_kiro() {
  local out line
  out="$("$@")" || return 1
  for line in "${(@f)out}"; do
    if [[ "$line" == 'mkdir -p "${HOME}/.local/bin"'* ]]; then
      print -r -- '[[ -d "${HOME}/.local/bin" ]] || '"$line"
    else
      print -r -- "$line"
    fi
  done
}

# starship init: PROMPT2 を生成時に展開した文字列で置き換える。
# 生成物の `PROMPT2="$(starship prompt --continuation)"` は source する度に
# starship を fork して ~14ms 掛かる。値は starship の version にしか依存
# しないので、キャッシュ生成時に一度だけ実行して literal として焼き込む。
#
# zsh-defer で後から代入する方法は使えない: kiro-cli の post ブロックが
# precmd で PROMPT2 を Q_USER_PROMPT2 に退避し preexec で復元するため、
# prompt 表示後の代入は次のコマンド実行時に巻き戻される。
zcache_gen_starship() {
  local out line cont
  out="$("$@")" || return 1
  for line in "${(@f)out}"; do
    if [[ "$line" == 'PROMPT2='* ]]; then
      # $1 は生成コマンドの starship 本体 (呼び出し側と同じものを使う)。
      cont="$("$1" prompt --continuation 2>/dev/null)"
      if [[ -n "$cont" ]]; then
        # (qq) = single quote 化。値には生の ESC が入るが、prompt 展開は
        # 表示時に行われるので literal のまま保持してよい。
        print -r -- "PROMPT2=${(qq)cont}"
        continue
      fi
      # 取得に失敗したら元の行を残す (fork は復活するが壊れない)。
    fi
    print -r -- "$line"
  done
}
