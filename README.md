# Dotfiles

[chezmoi](https://www.chezmoi.io/)で管理しているdotfilesリポジトリを公開用に通常のdotfilesの形式に修正し公開。

## 構成

| 役割                           | ツール                                                                                                                          | 対象                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| ユーザー設定                   | chezmoi                                                                                                                         | `.zshrc`, `~/.config/*`, `.hammerspoon/`, `.tmux.conf`, `.vimrc` |
| CLI パッケージ                 | [home-manager](https://github.com/nix-community/home-manager)                                                                   | `nix-config/home.nix` (macOS / Linux 共通)                       |
| macOS システム設定             | [nix-darwin](https://github.com/LnL7/nix-darwin)                                                                                | `nix-config/darwin.nix` (Homebrew cask, launchd, Touch ID sudo)  |
| GUI アプリ (macOS)             | Homebrew Cask                                                                                                                   | `nix-config/darwin.nix` の `homebrew.casks` で宣言                |

> Nix packages は `home.nix` で一元管理され、macOS / Linux で同じリストが共有されます。
> macOS では nix-darwin が home-manager を取り込む形で、Linux では standalone home-manager として適用できます。

## 新規マシンでのセットアップ

### macOS (nix-darwin + home-manager)

```sh
# 1. Nix を導入 (Determinate Systems Nix Installer)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. このリポを clone
git clone https://github.com/Tiger-0512/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix-config

# 3. nix-darwin を初回 bootstrap (sudo 必要、--impure は optional な社内 import を有効にするため)
sudo nix run nix-darwin -- switch --flake .#default --impure

# 4. 以後の更新
darwin-rebuild switch --flake .#default --impure
```

### Linux (Ubuntu / Amazon Linux 等)

```sh
# 1. Nix を導入
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. このリポを clone
git clone https://github.com/Tiger-0512/dotfiles.git ~/dotfiles
cd ~/dotfiles/nix-config

# 3. home-manager で初回 bootstrap
nix run home-manager/master -- init --switch --flake .#default
```

Linux では nix-darwin を使わないので、docker 等の system-level サービスが必要な場合は distro 側 (apt / dnf / systemd) で別途 install する。

### パッケージの更新

`flake.lock` で全 input (nixpkgs / nix-darwin / home-manager) が pin されているので、新しい版に上げたい時は lock を更新して再適用する。

```sh
cd ~/dotfiles/nix-config

# 全 input をまとめて更新
nix flake update

# diff 確認
git diff flake.lock

# macOS
darwin-rebuild switch --flake .#default --impure

# Linux
nix run home-manager/master -- switch --flake .#default
```

特定 input だけ更新する場合は `nix flake lock --update-input nixpkgs`(など)。

### 補足

- Touch ID for sudo は `darwin.nix` の `security.pam.services.sudo_local.touchIdAuth = true` で有効化済み (macOS のみ)
- Determinate Systems のインストーラ経由で Nix を入れているため、`darwin.nix` で `nix.enable = false` を設定し nix daemon の管理は Determinate 側に任せている
- `flake.lock` が置かれているのでバージョン固定された再現ビルドが可能
- `home.nix` には `commonPackages` / `darwinOnlyPackages` / `linuxOnlyPackages` の分岐があり、`colima` / `docker` 系は macOS のみ
- `--impure` は `chezmoi-internal/darwin-internal.nix` (ローカル管理) を条件付き import するため。該当ファイルがないマシンでは `--impure` を付けても挙動に影響しない

## 含まれる設定

| ツール                                                 | カテゴリ                | 設定ファイル                    |
| ------------------------------------------------------ | ----------------------- | ------------------------------- |
| Zsh                                                    | シェル                  | `.zshrc`                        |
| [Sheldon](https://github.com/rossmacarthur/sheldon)    | Zshプラグインマネージャ | `.config/sheldon/plugins.toml`  |
| [Starship](https://starship.rs/)                       | プロンプト              | `.config/starship.toml`         |
| Neovim                                                 | エディタ                | `.config/nvim/`                 |
| Vim                                                    | エディタ                | `.vimrc`                        |
| [Alacritty](https://alacritty.org/)                    | ターミナル              | `.config/alacritty/`            |
| [Ghostty](https://ghostty.org/)                        | ターミナル              | `.config/ghostty/config`        |
| [WezTerm](https://wezfurlong.org/wezterm/)             | ターミナル              | `.config/wezterm/`              |
| tmux                                                   | マルチプレクサ          | `.tmux.conf`                    |
| [Zellij](https://zellij.dev/)                          | マルチプレクサ          | `.config/zellij/config.kdl`     |
| [Yazi](https://yazi-rs.github.io/)                     | ファイルマネージャ      | `.config/yazi/`                 |
| [lf](https://github.com/gokcehan/lf)                   | ファイルマネージャ      | `.config/lf/`                   |
| Git                                                    | Git                     | `.config/git/`                  |
| [LazyGit](https://github.com/jesseduffield/lazygit)    | Git UI                  | `.config/lazygit/config.yml`    |
| [GitUI](https://github.com/extrawurst/gitui)           | Git UI                  | `.config/gitui/`                |
| [Hammerspoon](https://www.hammerspoon.org/)            | macOS自動化             | `.hammerspoon/`                 |

※ Alacritty, tmux, Zellij, lf, GitUIは現在利用していないため古い設定になっている可能性があります。

## 主要なツール

### Zsh プラグイン (Sheldon)

- [zsh-defer](https://github.com/romkatv/zsh-defer) - 遅延読み込み
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - シンタックスハイライト
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - 自動補完候補
- [zsh-completions](https://github.com/zsh-users/zsh-completions) - 追加の補完定義

### キーバインド

| キー              | 機能                                |
| ----------------- | ----------------------------------- |
| `Ctrl+f`          | Yaziでファイル操作                  |
| `Ctrl+g Ctrl+g`   | LazyGit起動                         |
| `Ctrl+g Ctrl+f`   | zoxideでディレクトリ移動 (fzf)      |

### Git設定

コミットメッセージは[Conventional Commits](https://www.conventionalcommits.org/)に基づくテンプレートを使用。

## Neovim

Luaベースの設定。主な機能:

- Leader: `,`
- カラースキーム: hybrid
- プラグイン管理: [lazy.nvim](https://github.com/folke/lazy.nvim)

## WezTerm / Ghostty

ターミナルエミュレータとしてWezTermをメインで使用。Ghosttyの設定も残している。

### 外観 (Ghostty)

- テーマ: Catppuccin Mocha
- 背景透過: 85%（ブラー半径20）
- フォント: FantasqueSansM Nerd Font Mono + Hiragino Kaku Gothic ProN

### キーバインド (Ghostty)

| キー                       | 機能                     |
| -------------------------- | ------------------------ |
| `Ctrl+Shift+'`             | 右に分割                 |
| `Ctrl+Shift+;`             | 下に分割                 |
| `Ctrl+Shift+h/j/k/l`       | ペイン移動 (左/下/上/右) |
| `Ctrl+Shift+Cmd+h/j/k/l`   | ペインリサイズ           |
| `Ctrl+Shift+u/i`           | スクロール (下/上)       |
| `Ctrl+Shift+t`             | 新規タブ                 |
| `Ctrl+Shift+,/.`           | タブ移動 (前/次)         |
| `Ctrl+Shift+w`             | 新規ウィンドウ           |

## Hammerspoon

macOS用の自動化ツール。ウィンドウ管理とキーリマップに使用。

### ウィンドウ管理

`Alt+Shift+Ctrl` をモディファイアキーとして使用。

| キー                   | 機能                                                 |
| ---------------------- | ---------------------------------------------------- |
| `Alt+Shift+Ctrl+h`     | フォーカスしているウインドウを左半分に移動           |
| `Alt+Shift+Ctrl+l`     | フォーカスしているウインドウを右半分に移動           |
| `Alt+Shift+Ctrl+k`     | フォーカスしているウインドウを上半分に移動           |
| `Alt+Shift+Ctrl+j`     | フォーカスしているウインドウを下半分に移動           |
| `Alt+Shift+Ctrl+b`     | フォーカスしているウインドウを右下 (60%幅) に移動    |
| `Alt+Shift+Ctrl+f`     | フォーカスしているウインドウをフルスクリーンに       |

### キーリマップ

Vimライクなカーソル移動をシステム全体で有効化。

| キー               | 機能                      |
| ------------------ | ------------------------- |
| `Ctrl+h/j/k/l`     | カーソル移動 (左/下/上/右) |
| `Ctrl+i`           | 行頭へ移動                |
| `Ctrl+a`           | 行末へ移動                |
| `Ctrl+w`           | 単語選択 (右方向)         |
| `Ctrl+Shift+w`     | 単語選択 (左方向)         |

### ターミナル起動

- `Option`キー2回押し: ターミナル (WezTerm/Ghostty) を起動/フォーカス
