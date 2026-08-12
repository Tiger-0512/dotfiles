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
#   zcache [-s <追加 stamp 文字列>] [-f <監視するファイル>] \
#          <name> <binary> <生成コマンド...>
#
# 例:
#   zcache zoxide zoxide zoxide init zsh
#
# -s は生成物が <binary> 以外の要素にも依存する場合に使う。
# 例: kiro-cli init の出力には生成時の zsh 実体 path が Q_SHELL として
# 焼き込まれる。zsh だけが更新されると古い Nix store path が残り、
# GC 後に figterm の起動が壊れる。-s で zsh の path も判定材料に含める。
#
# -f は生成物がユーザーの設定ファイルの内容にも依存する場合に使う。
# こちらはファイルの「内容」を stamp に含める (理由は下の実装コメント参照)。
#
# <binary> が PATH に無い場合は何もしない (未導入マシンでも安全)。

: ${ZCACHE_DIR:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh-init}

zcache() {
  local extra="" watch=""
  while true; do
    case "$1" in
      -s) extra="$2"; shift 2 ;;
      -f) watch="$2"; shift 2 ;;
      *)  break ;;
    esac
  done

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

  # 生成コマンドが自作フィルタならその定義内容も含める。
  # フィルタの実装だけを直した場合は $* が変わらないため、これが無いと
  # 古い生成物を掴み続ける (実際に踏んだ)。
  # 改行を空白に潰して 1 行に保つ ($(<file) の末尾改行剥がしと食い違わせない)。
  #
  # zcache_gen_* に限定するのが重要。単に $+functions[$1] で見ると、
  # `mise` のように「生成物を source した結果として同名の function が
  # 定義される」コマンドで stamp が揺れる。新規 shell では function 無し、
  # `source ~/.zshrc` した shell では function 有りになるため、両者の間で
  # 再生成が往復する (実際に踏んだ)。
  if [[ "$1" == zcache_gen_* ]] && (( $+functions[$1] )); then
    real="$real:${functions[$1]//$'\n'/ }"
  fi

  # -f で指定された設定ファイルの内容を含める。
  # ファイルが無い場合は項目自体を足さないので、後から作られれば差分になる。
  #
  # mtime ではなく内容にした理由が 2 つある:
  #   - mtime の精度は秒なので、同じ秒に 2 回編集されると差分を取り逃がす
  #   - 対象が chezmoi 管理下のファイルだと、chezmoi apply は内容が同じでも
  #     mtime を更新するため、mtime 判定では無駄な再生成が走る
  # $(<file) は zsh が内部で読むだけで fork しない (実測 0.14ms/回)。
  # 改行は空白に潰して stamp を 1 行に保つ。
  if [[ -n "$watch" && -r "$watch" ]]; then
    local content="$(<"$watch")"
    real="$real:$watch=${content//$'\n'/ }"
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

#-------------------- compinit のキャッシュ --------------------#
# compinit は fpath の全ディレクトリを glob して補完関数を探すため重い。
# 実測 (fpath 27 entries): page cache が cold で 2.6〜3.8s、warm でも ~78ms。
#
# -C を付けると走査を丸ごと省いて dump を source するだけになる (~25ms) が、
# compinit 自身の staleness 判定も飛ばす (compinit の実装では -C は
# _i_check を空にし、dump 内の `#files` 数と `version` の照合を通らずに
# 無条件で source する)。つまり素の -C には 2 つの穴がある:
#   - fpath に増えた補完関数が反映されない
#   - zsh を更新した時に別 version が書いた dump を無検証で読む
#
# そこで zcache と同じ発想で「判定材料が変わった時だけ全走査」する。
# 判定材料 (stamp) は:
#   - $ZSH_VERSION          … compinit 自身が見ているものと同じ
#   - fpath 各 entry の :A  … symlink 解決後の実体 path。
#     /run/current-system/sw/share/zsh/site-functions のような Nix profile
#     経由の path は「文字列が不変で mtime も 1970 固定」なので、これを
#     解決しないと nix-darwin / home-manager の更新を検出できない。
#     :A なら store hash が入るため更新で必ず変わる (subprocess 不要)。
#   - store 外 entry の mtime … /opt/homebrew/share/zsh/site-functions などに
#     brew install で補完ファイルが増えた場合を拾う。ディレクトリの mtime は
#     ファイル追加・削除で変わる。
#
# stamp の計算自体は fpath=14 で ~3.4ms。呼び出し側が zsh-defer 経由なので
# prompt 表示までの経路には乗らない。
#
# 判定材料が変わらないまま補完だけ増えた等で取り逃がした場合は
#   rm ~/.cache/zsh-init/compinit.stamp
# で次回起動時に全走査へ戻せる。
zcache_compinit() {
  local dump="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
  local stamp="$ZCACHE_DIR/compinit.stamp"

  zmodload -F zsh/stat b:zstat 2>/dev/null
  local d m real="$ZSH_VERSION"
  for d in $fpath; do
    real+=":${d:A}"
    [[ "$d" == /nix/store/* ]] && continue
    zstat +mtime -A m -- "$d" 2>/dev/null && real+="@$m"
  done

  autoload -Uz compinit

  local prev=""
  [[ -r "$stamp" ]] && prev=$(<"$stamp")
  if [[ -s "$dump" && "$prev" == "$real" ]]; then
    compinit -C -d "$dump"
    return 0
  fi

  [[ -d "$ZCACHE_DIR" ]] || mkdir -p "$ZCACHE_DIR"
  compinit -u -d "$dump"
  print -r -- "$real" > "$stamp"
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
#
# 注意: `starship init zsh` の出力自体は設定に依存しないが、ここで焼き込む
# `starship prompt --continuation` は starship.toml を読む。呼び出し側で
# -f に starship.toml を渡して stamp に含めること (でないと config を編集
# しても PROMPT2 が更新されない)。
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
