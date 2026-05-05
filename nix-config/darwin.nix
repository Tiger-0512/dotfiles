{ pkgs, ... }:

{
  # ------------------------------------------------------------------
  # Phase 2.2: 閲覧系 CLI を Homebrew から Nix 単一管理に移行。
  # 追加: git-delta (git pager), gh (GitHub CLI)
  # これらは従来 Homebrew で入れていたが、本 Phase で Homebrew からは
  # uninstall し、Nix 側だけで管理する (source-of-truth の一本化)。
  # ------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    bat
    eza
    ripgrep
    fd
    fzf
    delta       # git-delta (dandavison/delta): git pager
    gh
  ];

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
}
