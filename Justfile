#!/usr/bin/env just --justfile
# just <target> で dotfiles の運用タスクを実行する。
# 利用可能なタスクは `just` (引数なし) or `just --list` で確認できる。

# nix-config が chezmoi source tree 直下にある前提
nix_config := justfile_directory() / "nix-config"

# デフォルトでタスク一覧を表示
default:
    @just --list

# 新規 clone 直後の初回セットアップ (冪等)。
#   1. 禁止トークンリストを example から配置 (既存なら上書きしない)
#   2. git hook を有効化 (core.hooksPath = .githooks)
# Nix / chezmoi 自体の導入はこの recipe より前に必要 (just は Nix 管理のため)。
[doc('新規 clone 直後の初回セットアップ (禁止トークンリスト + git hook)')]
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    if [[ -f scripts/forbidden-tokens.txt ]]; then
      echo "exists: scripts/forbidden-tokens.txt (上書きしない)"
    else
      cp scripts/forbidden-tokens.txt.example scripts/forbidden-tokens.txt
      echo "created: scripts/forbidden-tokens.txt"
      echo "  -> 社内ルールに従い 1 行 1 識別子で編集してから commit すること"
    fi
    bash scripts/install-hooks.sh

# dotfiles を $HOME に反映 (chezmoi apply)
apply:
    chezmoi apply

# public mirror の変換結果を検証 (nix fixtures 込み)
verify:
    bash scripts/verify-public-sync.sh --with-nix-fixtures

# nix flake の可変 input (nixpkgs / nix-darwin / home-manager) を最新化。
# release tag 固定の herdr は flake.nix の tag を変更してから lock を更新する。
[doc('nix flake の可変 input を最新化')]
flake-update:
    cd {{ nix_config }} && nix flake update

# nix flake を評価してエラーがないか確認
flake-check:
    cd {{ nix_config }} && nix flake check --no-eval-cache --impure

# macOS: Homebrew の formula / cask database を更新。
# darwin.nix で onActivation.autoUpdate = false にしているため、cask を新規追加した
# 直後や版を上げたい時だけ手動で実行する (switch には含めない)。
[macos]
[doc('macOS: Homebrew の formula / cask database を更新')]
brew-update:
    brew update

# macOS: nix-darwin + home-manager を反映 (要 sudo, --impure は conditional import 用)
# switch 後に rift-service を流して window manager の launchd 登録を追従させる。
[macos]
[doc('macOS: nix-darwin + home-manager を反映 (要 sudo)')]
switch: && rift-service
    sudo USER=$USER darwin-rebuild switch --flake {{ nix_config }}#default --impure

# macOS: Rift (tiling window manager) の launchd service を起動・追従させる。
#
# `rift service start` だけで足りる。plist が無ければ作成し、内容が古ければ
# (Nix の実行ファイルパスが変わった場合など) 書き換えてから kickstart する自己修復
# 動作なので、switch 後に毎回流して良い。逆に `rift service install` は plist が
# 既にあると AlreadyExists で失敗するため、繰り返し実行する経路では使わない。
#
# home.activation ではなく just 側に置いている理由: launchctl の bootstrap は
# 利用者の GUI session (gui/$UID) を対象にするため、sudo darwin-rebuild の
# activation 内から実行すると uid / session が合わず失敗しうる。
[macos]
[doc('macOS: Rift の launchd service を起動・追従 (switch から自動実行)')]
rift-service:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v rift >/dev/null 2>&1; then
      echo "skip: rift not on PATH (switch 未実行?)" >&2
      exit 0
    fi
    rift service start
    echo "rift service started (初回はアクセシビリティ権限の許可と alt+z が必要)"

# Linux: standalone home-manager を反映
#   --impure = flake.nix が builtins.getEnv "USER" を使うため
#   NIXPKGS_ALLOW_UNFREE=1 = kiro-cli が unfree のため
[linux]
[doc('Linux: standalone home-manager を反映')]
switch:
    cd {{ nix_config }} && NIXPKGS_ALLOW_UNFREE=1 nix run --impure home-manager/master -- switch --flake .#default

# flake-update + switch (= 更新運用のワンショット)
update: flake-update switch

# PR 本文の禁止トークン事前チェック (file 指定, stdin は -)
check-pr file:
    bash scripts/check-pr-body.sh {{ file }}
