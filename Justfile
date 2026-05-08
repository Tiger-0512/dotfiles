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
[linux]
switch:
    cd {{ nix_config }} && nix run home-manager/master -- switch --flake .#default

# flake-update + switch (= 更新運用のワンショット)
update: flake-update switch

# PR 本文の禁止トークン事前チェック (file 指定, stdin は -)
check-pr file:
    bash scripts/check-pr-body.sh {{ file }}

# Linux (Docker) で home-manager switch のスモークテストを実行
# 要 docker。初回は 10〜15 分 (Nix install + package download)。
linux-smoke:
    bash scripts/linux-smoke-test.sh
