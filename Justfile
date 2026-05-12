#!/usr/bin/env just --justfile
# just <target> で dotfiles の運用タスクを実行する。
# 利用可能なタスクは `just` (引数なし) or `just --list` で確認できる。

# nix-config が chezmoi source tree 直下にある前提
nix_config := justfile_directory() / "nix-config"

# デフォルトでタスク一覧を表示
default:
    @just --list

# dotfiles を $HOME に反映 (chezmoi apply)
apply:
    chezmoi apply

# public mirror の変換結果を検証 (nix fixtures 込み)
verify:
    bash scripts/verify-public-sync.sh --with-nix-fixtures

# nix flake の全 input (nixpkgs / nix-darwin / home-manager) を最新化
flake-update:
    cd {{ nix_config }} && nix flake update

# nix flake を評価してエラーがないか確認
flake-check:
    cd {{ nix_config }} && nix flake check --no-eval-cache --impure

# macOS: nix-darwin + home-manager を反映 (要 sudo, --impure は conditional import 用)
[macos]
switch:
    sudo darwin-rebuild switch --flake {{ nix_config }}#default --impure

# Linux: standalone home-manager を反映
#   --impure = flake.nix が builtins.getEnv "USER" を使うため
#   NIXPKGS_ALLOW_UNFREE=1 = kiro-cli が unfree のため
[linux]
switch:
    cd {{ nix_config }} && NIXPKGS_ALLOW_UNFREE=1 nix run --impure home-manager/master -- switch --flake .#default

# flake-update + switch (= 更新運用のワンショット)
update: flake-update switch

# PR 本文の禁止トークン事前チェック (file 指定, stdin は -)
check-pr file:
    bash scripts/check-pr-body.sh {{ file }}
