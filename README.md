# Dotfiles

[chezmoi](https://www.chezmoi.io/)で管理しているdotfilesリポジトリを公開用に通常のdotfilesの形式に修正し公開。

## 含まれる設定

| ツール | カテゴリ | 設定ファイル |
|--------|---------|-------------|
| Zsh | シェル | `.zshrc` |
| [Sheldon](https://github.com/rossmacarthur/sheldon) | Zshプラグインマネージャ | `.config/sheldon/plugins.toml` |
| [Starship](https://starship.rs/) | プロンプト | `.config/starship.toml` |
| Neovim | エディタ | `.config/nvim/` |
| Vim | エディタ | `.vimrc` |
| [Alacritty](https://alacritty.org/) | ターミナル | `.config/alacritty/` |
| [Ghostty](https://ghostty.org/) | ターミナル | `.config/ghostty/config` |
| tmux | マルチプレクサ | `.tmux.conf` |
| [Zellij](https://zellij.dev/) | マルチプレクサ | `.config/zellij/config.kdl` |
| [Yazi](https://yazi-rs.github.io/) | ファイルマネージャ | `.config/yazi/` |
| [lf](https://github.com/gokcehan/lf) | ファイルマネージャ | `.config/lf/` |
| Git | Git | `.config/git/` |
| [LazyGit](https://github.com/jesseduffield/lazygit) | Git UI | `.config/lazygit/config.yml` |
| [GitUI](https://github.com/extrawurst/gitui) | Git UI | `.config/gitui/` |
| [Hammerspoon](https://www.hammerspoon.org/) | macOS自動化 | `.hammerspoon/` |

※ Alacritty, tmux, Zellij, lf, GitUIは現在利用していないため古い設定になっている可能性があります。

## 主要なツール

### Zsh プラグイン (Sheldon)

- [zsh-defer](https://github.com/romkatv/zsh-defer) - 遅延読み込み
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) - シンタックスハイライト
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) - 自動補完候補
- [zsh-completions](https://github.com/zsh-users/zsh-completions) - 追加の補完定義

### キーバインド

| キー | 機能 |
|------|------|
| `Ctrl+f` | Yaziでファイル操作 |
| `Ctrl+g Ctrl+g` | LazyGit起動 |
| `Ctrl+g Ctrl+f` | zoxideでディレクトリ移動 (fzf) |

### Git設定

コミットメッセージは[Conventional Commits](https://www.conventionalcommits.org/)に基づくテンプレートを使用。

## Neovim

Luaベースの設定。主な機能:

- Leader: `,`
- カラースキーム: hybrid
- プラグイン管理: [lazy.nvim](https://github.com/folke/lazy.nvim)

## Ghostty

### 外観

- テーマ: Catppuccin Mocha
- 背景透過: 85%（ブラー半径20）
- フォント: FantasqueSansM Nerd Font Mono + Hiragino Kaku Gothic ProN

### キーバインド

| キー | 機能 |
|------|------|
| `Ctrl+Shift+'` | 右に分割 |
| `Ctrl+Shift+;` | 下に分割 |
| `Ctrl+Shift+h/j/k/l` | ペイン移動 (左/下/上/右) |
| `Ctrl+Shift+Cmd+h/j/k/l` | ペインリサイズ |
| `Ctrl+Shift+u/i` | スクロール (下/上) |
| `Ctrl+Shift+t` | 新規タブ |
| `Ctrl+Shift+,/.` | タブ移動 (前/次) |
| `Ctrl+Shift+w` | 新規ウィンドウ |

## Hammerspoon

macOS用の自動化ツール。ウィンドウ管理とキーリマップに使用。

### ウィンドウ管理

`Alt+Shift+Ctrl` をモディファイアキーとして使用。

| キー | 機能 |
|------|------|
| `Alt+Shift+Ctrl+h` | フォーカスしているウインドウを左半分に移動 |
| `Alt+Shift+Ctrl+l` | フォーカスしているウインドウを右半分に移動 |
| `Alt+Shift+Ctrl+k` | フォーカスしているウインドウを上半分に移動 |
| `Alt+Shift+Ctrl+j` | フォーカスしているウインドウを下半分に移動 |
| `Alt+Shift+Ctrl+b` | フォーカスしているウインドウを右下 (60%幅) に移動 |
| `Alt+Shift+Ctrl+f` | フォーカスしているウインドウをフルスクリーンに |

### キーリマップ

Vimライクなカーソル移動をシステム全体で有効化。

| キー | 機能 |
|------|------|
| `Ctrl+h/j/k/l` | カーソル移動 (左/下/上/右) |
| `Ctrl+i` | 行頭へ移動 |
| `Ctrl+a` | 行末へ移動 |
| `Ctrl+w` | 単語選択 (右方向) |
| `Ctrl+Shift+w` | 単語選択 (左方向) |

### ターミナル起動

- `Option`キー2回押し: Ghosttyを起動/フォーカス
