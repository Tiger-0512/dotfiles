{ pkgs, ... }:

{
  # ------------------------------------------------------------------
  # Nix 管理の CLI / システムパッケージ (macOS, aarch64-darwin)
  # 追加する時は nixpkgs-unstable の attribute 名を確認すること。
  # ------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Viewers / searchers
    bat
    eza
    ripgrep
    fd
    fzf
    delta        # git-delta (dandavison/delta): git pager
    gh

    # Shell integrations / task runners
    jq
    yq-go        # mikefarah/yq (Go). nixpkgs の 'yq' は Python 版なので避ける
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
    python3Packages.docutils   # rst2html などの scripts を提供

    # Editor / multiplexers / TUI
    neovim
    tmux
    zellij
    yazi
    lazygit
    # oxker: Apple Silicon macOS 環境で snapshot テスト ('Alt' vs 'Option' 表示差)
    # が失敗するため、ビルド時のテストをスキップする。機能自体に問題はない。
    (oxker.overrideAttrs (prev: { doCheck = false; }))

    # Container runtime (macOS では colima が docker daemon を提供)
    colima
    docker
    docker-compose
    docker-credential-helpers   # docker-credential-osxkeychain などを提供

    # AWS / IaC
    awscli2                        # nixpkgs 'awscli' は v1 系なので v2 の awscli2 を選択
    aws-cdk-cli                    # AWS CDK Toolkit (コマンド名は cdk)
    git-remote-codecommit          # AWS CodeCommit 用 git remote helper

    # Version manager + project-agnostic CLI toolchains
    mise                           # asdf / volta の後継 (.tool-versions / .mise.toml を参照)
    rustup                         # rustc / cargo の toolchain 管理
    pnpm
    uv                             # 高速な Python package / env manager
    python3Packages.virtualenv     # uv venv で代替可だが明示利用のため残置

    # 本体 / 補助ツール
    chezmoi                        # このリポジトリ自体の管理 tool
    git-filter-repo                # git history 書き換え用 (時々使う)
  ];

  # colima をログイン時に自動起動する LaunchAgent。
  # colima start は VM を起動したら exit する (detached 設計) ので
  # KeepAlive は false にして launchd のプロセス監視を無効化する。
  # VM 本体 (lima) は background で常駐する。
  #
  # launchd は PATH を継承しないので EnvironmentVariables で明示する必要あり。
  # colima が内部で呼び出す 'docker' CLI を Nix 管理下で解決させる。
  launchd.user.agents.colima = {
    serviceConfig = {
      ProgramArguments = [ "${pkgs.colima}/bin/colima" "start" ];
      RunAtLoad = true;
      KeepAlive = false;
      StandardOutPath = "/Users/taigamat/Library/Logs/colima.out.log";
      StandardErrorPath = "/Users/taigamat/Library/Logs/colima.err.log";
      EnvironmentVariables = {
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # nix コマンドで flakes を使えるようにする
  # (Determinate Systems インストーラなら既に有効化済みのはず)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Determinate Systems Nix Installer を使う場合、Nix daemon の管理は
  # Determinate 側に任せ、nix-darwin の nix サブシステムは無効化する。
  # これを有効にすると launchd service が二重管理になって壊れる。
  nix.enable = false;

  # nix-darwin state version
  # 初回適用後は上げないこと (upgrade 手順を踏む必要がある)
  system.stateVersion = 5;

  # Touch ID for sudo を nix-darwin 管理下で有効化
  # (macOS 標準の /etc/pam.d/sudo_local の内容を代替)
  security.pam.services.sudo_local.touchIdAuth = true;

  # nix-darwin の最近の版では primary user を明示する必要がある
  system.primaryUser = "taigamat";

  # ログインユーザー定義
  users.users.taigamat = {
    name = "taigamat";
    home = "/Users/taigamat";
  };

  # Homebrew cask / tap の宣言管理
  # cleanup は "none" のまま。flake の pure evaluation では
  # builtins.pathExists が絶対パスに対して false を返すため、
  # chezmoi-internal/darwin-internal.nix の conditional import が効かない。
  # "uninstall" にすると社内 tap / formula が意図せず消えるので避ける。
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };

    taps = [
      "manaflow-ai/cmux"
    ];

    casks = [
      "ghostty"
      "wezterm"
      "visual-studio-code"
      "zed"
      "brave-browser"
      "cmux"
      "claude-code"
      "kiro-cli"
      "corretto"
      "session-manager-plugin"
      "raycast"
      "hammerspoon"
      "alt-tab"
      "betterdisplay"
      "hiddenbar"
      "appcleaner"
      "deskpad"
      "obsidian"
      "ollama-app"
      "font-fantasque-sans-mono"
      "font-fantasque-sans-mono-nerd-font"
      "font-hack-nerd-font"
      "asana"
    ];
  };

  # NOTE: 社内専用の nix-darwin 設定 (chezmoi-internal/darwin-internal.nix) の
  # conditional import は flake の pure evaluation で builtins.pathExists が
  # 絶対パスに対して false を返すため機能しなかった。
  # 対応案 (将来): --impure で darwin-rebuild、flake inputs に path URI、
  # nix-config/ 内への symlink、etc. 要検討。
  # 現状は社内 tap / brew は手動管理 (cleanup = "none" 前提)。
}
