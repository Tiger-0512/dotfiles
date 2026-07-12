{ pkgs, lib, config, ... }:

let
  # oxker の aarch64-darwin での snapshot テスト問題を回避するため、
  # macOS のみ doCheck = false で build する。Linux では素のまま。
  oxkerForPlatform =
    if pkgs.stdenv.isDarwin
    then pkgs.oxker.overrideAttrs (_prev: { doCheck = false; })
    else pkgs.oxker;

  # macOS / Linux 共通の package 群。
  # 将来追加するもの (project-agnostic な CLI) は基本ここに追加する。
  commonPackages = with pkgs; [
    # Viewers / searchers
    bat
    eza
    ripgrep
    fd
    fzf
    delta
    gh

    # Shell integrations / task runners
    jq
    yq-go
    zoxide
    direnv
    starship
    sheldon
    git-lfs
    just

    # Build / lint / format
    cmake
    cloc
    shellcheck
    yamlfmt
    biome
    tree-sitter
    python3Packages.docutils

    # Editor / multiplexers / TUI
    neovim
    tmux
    zellij
    yazi
    lazygit
    oxkerForPlatform

    # AWS / IaC
    awscli2
    aws-cdk-cli
    git-remote-codecommit

    # Version manager + project-agnostic toolchains
    mise
    rustup
    pnpm
    uv
    python3Packages.virtualenv

    # 本体 / 補助ツール
    chezmoi
    git-filter-repo

    # フォント (home-manager が macOS では ~/Library/Fonts/HomeManager、
    # Linux では ~/.local/share/fonts に配置する)
    fantasque-sans-mono
    nerd-fonts.fantasque-sans-mono
  ];

  # macOS 固有の package。
  # colima: macOS 上で Linux VM + Docker engine を提供。Linux では不要 (native)。
  # docker / docker-compose / docker-credential-helpers: macOS では colima と組で
  #   CLI を Nix 管理する。Linux では distro 側 (apt/dnf) で daemon + CLI を用意する方針。
  darwinOnlyPackages = with pkgs; [
    colima
    docker
    docker-compose
    docker-credential-helpers
  ];

  # Linux 固有の package (現時点で空)。
  linuxOnlyPackages = [ ];

  platformPackages =
    if pkgs.stdenv.isDarwin then darwinOnlyPackages
    else if pkgs.stdenv.isLinux then linuxOnlyPackages
    else [ ];

  # private マシン (chezmoi data の private=true) でのみ管理する package。
  # 判定は chezmoi が private マシンにだけ配置する marker
  # (~/.config/nix-personal-enabled、.chezmoiignore 参照) の存在で行う。
  # marker 判定 (source tree 外の絶対パスへの pathExists) には --impure が必要だが、
  # darwin-switch / Linux 側 home-manager switch のどちらも --impure を付与済み。
  # config.home.homeDirectory は macOS=/Users/<user>, Linux=/home/<user> を解決するので
  # 両 OS で正しい marker パスになる。
  nixPersonalEnabled =
    builtins.pathExists "${config.home.homeDirectory}/.config/nix-personal-enabled";

  personalPackages = lib.optionals nixPersonalEnabled (with pkgs; [
    kiro-cli
  ]);
in
{
  home.stateVersion = "25.05";

  home.packages = commonPackages ++ platformPackages ++ personalPackages;

  # home-manager 自体の self-management を有効化
  programs.home-manager.enable = true;

  # dotfiles は chezmoi が管理するため、home-manager 側では program 単位の
  # dotfile 生成 (programs.git, programs.zsh など) は使用しない。
}
