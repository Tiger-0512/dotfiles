# Dotfiles

[chezmoi](https://www.chezmoi.io/)で管理しているdotfilesリポジトリを公開用に通常のdotfilesの形式に修正し公開。

## 構成

| 役割                           | ツール                                                                                                                          | 対象                                                             |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| ユーザー設定                   | chezmoi                                                                                                                         | `.zshrc`, `~/.config/*`, `.hammerspoon/`, `.tmux.conf`, `.vimrc` |
| CLI パッケージ                 | [home-manager](https://github.com/nix-community/home-manager)                                                                   | `nix-config/home.nix` (macOS / Linux 共通)                       |
| macOS システム設定             | [nix-darwin](https://github.com/LnL7/nix-darwin)                                                                                | `nix-config/darwin.nix` (Homebrew cask, launchd, Touch ID sudo)  |
| GUI アプリ (macOS)             | Homebrew Cask                                                                                                                   | `nix-config/darwin.nix` の `homebrew.casks` で宣言                |
| Agent workspace                | [Herdr](https://herdr.dev/)                                                                                                    | 公式 Nix flake の安定版タグを固定し、macOS / Linux 共通で導入    |
| ウィンドウ管理 (macOS)         | [Rift](https://github.com/acsandmann/rift)                                                                                      | `nix-config/home.nix` の macOS 専用 package として導入            |

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
#    - `switch` を使う (`init --switch` は flake の homeConfigurations を
#      無視してテンプレート home.nix を当ててしまうため NG)
#    - `--impure` は flake.nix の `builtins.getEnv "USER"` のため必要。
#      2 箇所に必要な点に注意:
#        * `nix run --impure` … home-manager 本体を取得する外側の nix
#        * `-- switch ... --impure` … home-manager が内部で呼ぶ nix build に
#          転送される。これが無いと getEnv が空文字列を返し
#          `A definition for option 'home.username' is not of type
#           'non-empty string'` で落ちる。
#    - `NIXPKGS_ALLOW_UNFREE=1` は kiro-cli (unfree) を入れるため必要
NIXPKGS_ALLOW_UNFREE=1 nix run --impure home-manager/master -- \
    switch --flake .#default --impure
```

Linux では nix-darwin を使わないので、docker 等の system-level サービスが必要な場合は distro 側 (apt / dnf / systemd) で別途 install する。

### パッケージの更新

`flake.lock` で全 input (nixpkgs / nix-darwin / home-manager / herdr) が pin されているので、新しい版に上げたい時は lock を更新して再適用する。

```sh
cd ~/dotfiles/nix-config

# 全 input をまとめて更新
nix flake update

# diff 確認
git diff flake.lock

# macOS
darwin-rebuild switch --flake .#default --impure

# Linux
# 末尾の --impure は home-manager が内部で呼ぶ nix build 用
# (前段の `nix run --impure` とは別に必要)。
NIXPKGS_ALLOW_UNFREE=1 nix run --impure home-manager/master -- \
    switch --flake .#default --impure
```

特定 input だけ更新する場合は `nix flake update nixpkgs`(など)。

Herdr は公式推奨に従い release tag を固定している。新しい安定版へ更新する場合は、
`flake.nix` の `github:herdrdev/herdr/vX.Y.Z` を変更してから
`nix flake update herdr` を実行する。

Herdr の設定は `.config/herdr/config.toml` で管理する。Claude Code / Codex /
Kiro CLI の macOS 日本語 IME 対応を有効にし、機密情報を含み得る pane history は
無効にしている。WezTerm の Kitty graphics 対応を利用し、Herdr 内の Yazi で画像と
PDF をプレビューする。Markdown は Yazi 既定のシンタックスハイライト表示を利用する。
Native agent session restore は Claude Code と Codex で利用する。Kiro CLI は現行
Herdr では状態検出のみで、native session restore の対象外。zsh completion は Nix
適用時に pinned Herdr から生成する。background agent の完了と入力待ちは、Herdr
client が detach されていても OS の desktop notification で表示する。
tab / pane / space 操作は prefix なしの direct keybinding とし、必須の prefix は
`F24` へ退避する。`ctrl+esc` で detach し、`ctrl+shift+t`、`ctrl+shift+h/l`、
`ctrl+shift+k/j`、`ctrl+s`、`ctrl+n/m/,/.`、`ctrl+;` / `ctrl+'`、
`ctrl+shift+r`、`ctrl+shift+y` を tab 作成、tab 移動、space 移動 (上 / 下)、
space 新規作成、pane 移動、pane 分割、pane resize mode、copy mode に割り当てる。
WezTerm は修飾が失われるキー (`ctrl+shift+<英字>`、legacy encoding が `Enter` と
同じ `ctrl+m`、legacy control code の無い `ctrl+,` / `ctrl+.` / `ctrl+;` /
`ctrl+'`) を CSI-u sequence として Herdr へ送る。Herdr client が要求する kitty
keyboard protocol (`CSI >7u`) は WezTerm の既定 (`enable_kitty_keyboard = false`)
では無視されるため、この変換が無いキーは SSH 越しの remote Herdr でも届かない。
scroll は Herdr の `[keys]` に action が無く、client が scroll を発行する入力経路は
マウスホイールと修飾なしの `pageup` / `pagedown` (ページ単位) の 2 つだけ。行単位で
動かしたいので `ctrl+shift+s` (下) / `ctrl+shift+d` (上) は Hammerspoon の
`hs.eventtap.event.newScrollEvent` で本物のスクロールホイールイベントを送る形にし、
Herdr の `[ui] mouse_scroll_lines` (既定 3 行) 単位で動かす。WezTerm 以外の
全アプリでも同じキーで scroll できる。ホイールイベントはキーボードフォーカスでは
なくイベント座標で配送先が決まるため、座標を前面ウィンドウの中心に設定して前面
アプリへ直接 post している (pane 分割時はフォーカス中の pane ではなくウィンドウ中心
の pane が動くので、フォーカス基準で動かしたい時は素の `pageup` / `pagedown` を
使う)。
`ctrl+a` は入力待ち (`blocked`) の agent の pane へ focus する。Herdr にはこの
action が無いため、`[[keys.command]]` の shell 実行から
`.config/herdr/focus-waiting-agent.sh` を呼び、`herdr agent list` の状態を見て
`herdr agent focus` する。`blocked` を優先し、次に `done`。連打でキューを巡回する。
Hammerspoon の `ctrl+w` / `ctrl+shift+w` (単語選択)、`ctrl+a` (行末) のリマップは
WezTerm が前面の間だけ無効化し、他のアプリでは維持する
(`hs.hotkey` はシステム全体で先にキーを奪うため)。これらの direct keybinding は
Herdr 内の pane application より優先される。tab / pane の管理は Herdr に一元化したため
WezTerm 側の tab bar は非表示にし、tab タイトルの装飾と tab bar 上のモード表示は
廃止する。tab / pane / scroll / copy mode の WezTerm 既定 keybinding も
`DisableDefaultAssignment` で無効化してキーを Herdr へ通し、WezTerm 側には
`ctrl+shift+w` の新規ウィンドウ、`ctrl+shift+f` の検索、`ctrl+shift+/` の
QuickSelect、`ctrl+shift+n` の通知ビューア、コピー / 貼り付け、
フォントサイズ変更だけを残す。
ローカルの対話型 terminal では `.zshrc` から session list を `fzf` で表示し、
既存 session の開始・再接続または名前つき session の新規作成を選べる。Esc なら
通常 shell に残る。Herdr pane 内、SSH、tmux / Zellij、IDE 内 terminal、非 TTY は
対象外で、一時的に無効化する場合は `HERDR_DISABLE_AUTO_ATTACH=1 zsh` を使う。
Claude Code と Codex の integration は、各 agent の設定 directory が存在する場合に
home-manager activation から冪等に自動導入する。agent を初めて起動した後にまだ
integration がなければ、home-manager / darwin switch を再実行する:

```sh
herdr integration status
```

### Rift (macOS の tiling window manager)

[Rift](https://github.com/acsandmann/rift) は nixpkgs の `rift-wm` として
`home.nix` の macOS 専用 package で導入する。`meta.platforms` が `aarch64-darwin`
のみなので Apple Silicon 専用で、Linux の `homeConfigurations` には含まれない。

switch ではインストールまでしか行われないので、launchd への登録は Rift 自身の
subcommand で行う。`Justfile` の `rift-service` recipe に寄せてあり、`just switch`
から後続実行されるため通常は手動操作が不要。`rift service start` は plist の作成と
内容の再同期を含む冪等な自己修復動作なので、switch のたびに流して問題ない
(`rift service install` は plist が既にあると失敗するため使わない)。

その後 macOS のアクセシビリティ権限を許可する。権限付与後は `rift service restart`
が必要。既定では space が非管理状態で始まるので、`alt+z` (`⌥Z`) または
`rift-cli execute toggle-space-activated` で管理を有効化する (SIP の無効化は不要)。

```sh
just rift-service   # = rift service start (単体で叩く場合)
```

設定は `.config/rift/config.toml` で管理する。**上流 `rift.default.toml` の全文
コピーがベース**で、差分だけを書くことはできない。rift は config をデフォルトと
マージせず丸ごとパースし、`settings` / `keys` / `virtual_workspaces` が必須
フィールドなので、一部だけ書くと `keys` が空になり `alt+z` を含む全キーバインドが
消える。上流からの変更点はファイル冒頭のコメントに列挙している。

反映は再起動不要:

```sh
rift-cli execute config reload
```

`[settings.ui.menu_bar] enabled = true` にしてメニューバー表示を有効にしている。
常時見える帯は workspace インジケータで、クリックして開くドロップダウンの
`Enable Tiling` のチェックマークが `alt+z` の状態 (space の管理 on/off) を示す。

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
| [Herdr](https://herdr.dev/)                            | Agent workspace         | `.config/herdr/config.toml`     |
| [Yazi](https://yazi-rs.github.io/)                     | ファイルマネージャ      | `.config/yazi/`                 |
| [lf](https://github.com/gokcehan/lf)                   | ファイルマネージャ      | `.config/lf/`                   |
| Git                                                    | Git                     | `.config/git/`                  |
| [LazyGit](https://github.com/jesseduffield/lazygit)    | Git UI                  | `.config/lazygit/config.yml`    |
| [GitUI](https://github.com/extrawurst/gitui)           | Git UI                  | `.config/gitui/`                |
| [Hammerspoon](https://www.hammerspoon.org/)            | macOS自動化             | `.hammerspoon/`                 |
| [Rift](https://github.com/acsandmann/rift)             | ウィンドウ管理 (macOS)  | `.config/rift/config.toml`      |

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
| `Ctrl+i`           | 行頭へ移動 (WezTerm では無効) |
| `Ctrl+a`           | 行末へ移動 (WezTerm では無効) |
| `Ctrl+w`           | 単語選択 (右方向、WezTerm では無効) |
| `Ctrl+Shift+w`     | 単語選択 (左方向、WezTerm では無効) |
| `Ctrl+,` / `Ctrl+.`| スクロール (下 / 上、全アプリ共通)  |

### ターミナル起動

- `Option`キー2回押し: ターミナル (WezTerm/Ghostty) を起動/フォーカス
