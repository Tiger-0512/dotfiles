{ pkgs, lib, username, ... }:

{
  # ------------------------------------------------------------------
  # macOS system-level 設定 (nix-darwin)
  # Nix で入れる packages 自体は home-manager (./home.nix) に一本化しているので
  # このファイルでは environment.systemPackages を持たない。
  # Touch ID sudo / Homebrew cask / launchd agent / primaryUser など macOS 固有の
  # 設定だけをここに書く。
  # ------------------------------------------------------------------

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
      StandardOutPath = "/Users/${username}/Library/Logs/colima.out.log";
      StandardErrorPath = "/Users/${username}/Library/Logs/colima.err.log";
      EnvironmentVariables = {
        PATH = "/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  # Apple Silicon
  nixpkgs.hostPlatform = "aarch64-darwin";

  # unfree license の package を package 名 allowlist で個別許可する。
  # 全体許可 (allowUnfree = true) は広すぎるため、明示的に必要なものだけ通す。
  # - kiro-cli: 本体は unfree の Amazon 配布バイナリ。機能は CLI のみ。
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "kiro-cli"
    ];

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
  system.primaryUser = username;

  # ログインユーザー定義
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  # Homebrew cask / tap の宣言管理
  #
  # cleanup = "uninstall": 宣言にない formula / cask は darwin-rebuild 時に
  # 自動 uninstall される。社内固有の tap / formula を保持したい場合は
  # 下の imports で読み込む chezmoi-internal/darwin-internal.nix 側で宣言する。
  #
  # darwin-rebuild switch には --impure が必要。
  # flake の pure evaluation では builtins.pathExists が source tree 外の
  # 絶対パスに対して常に false を返すため、impure モードでないと下の
  # conditional import が機能しない。alias darwin-switch が --impure を付けている。
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "uninstall";
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
      "font-hack-nerd-font"
      "asana"
    ];
  };

  # 社内専用の nix-darwin 設定を条件付きで import する。
  # 存在しないマシン (個人 Mac など) では import されず、darwin.nix 側で
  # 宣言した分だけが有効になる。
  # darwin-rebuild switch には --impure が必要 (上の homebrew コメント参照)。
  imports =
    lib.optional
      (builtins.pathExists /Users/${username}/.local/share/chezmoi-internal/darwin-internal.nix)
      /Users/${username}/.local/share/chezmoi-internal/darwin-internal.nix
    ++ lib.optional
      (builtins.pathExists /Users/${username}/.config/nix-personal-enabled)
      ./darwin-personal.nix;
}
