{ pkgs, ... }:

{
  # ------------------------------------------------------------------
  # Phase 2.1 PoC: 最小構成 5 パッケージで nix-darwin を動作確認する。
  # これらは既に Homebrew でも入っているので、PATH 順序によっては
  # Homebrew 側が優先される可能性がある。nix の /run/current-system/sw/bin
  # が PATH の先頭に来ていれば Nix 側が使われる。
  # 共存検証のため Homebrew のパッケージはまだ削除しない。
  # ------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    bat
    eza
    ripgrep
    fd
    fzf
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
