# My Dotfiles (Vim/NeoVim, Zsh, Alacritty, Hammerspoon, Tig)

## Table of Contents
- [Zsh](#zsh)
- [NeoVim](#neovim)
- [Alacritty](#alacritty)
- [LF](#lf)
- [Git](#git)
- [GitUI](#gitui)
- [tmux](#tmux)
- [Hammerspoon](#hammerspoon)
- [Tig](#tig)


<a id="zsh"></a>
## Zsh
### Usage
```
$ ln -snvf $(pwd)/zsh/.zshrc ~/.zshrc
```
### Notice
- Before use, please install [zinit](https://github.com/zdharma/zinit).
- In this setting, I use [aura-theme](https://github.com/daltonmenezes/aura-theme). You can use this theme with [its installation guide](https://github.com/daltonmenezes/aura-theme/tree/main/packages/alacritty).
- Also, I use [Starship Prompt](https://starship.rs/). The below command sets my starship settings.
```
$ ln -snvf $(pwd)/zsh/starship/starship.toml ~/.config/starship.toml
```

<a id="neovim"></a>
## NeoVim
### Usage
NeoVim
```
$ ln -snvf $(pwd)/neovim ~/.config/nvim
```

<a id="alacritty"></a>
## Alacritty
### Usage
```
$ ln -snvf $(pwd)/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
```

<a id="lf"></a>
## LF
### Usage
```
$ ln -snvf $(pwd)/lf ~/.config
```

<a id="git"></a>
## Git
### Usage
```
$ mkdir -p ~/.config/git

# Global gitignore
$ cp ./dotfiles/git/ignore ~/.config/git

# Settings for conventional commits
$ cp ./dotfiles/git/conventional-commits-template ~/.config/git
$ git config --global commit.template ~/.config/git/conventional-commits-template
```
### Notice
The setting is based on below two rules.
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Contributing to Angular](https://github.com/angular/angular/blob/master/CONTRIBUTING.md)


<a id="gitui"></a>
## GitUI
### Usage
```
$ ln -snvf $(pwd)/gitui ~/.config
```


<a id="tmux"></a>
## tmux
### Usage
```
$ ln -snvf $(pwd)/tmux/.tmux.conf ~/.tmux.conf
```

<a id="hammerspoon"></a>
## Hammerspoon
### Usage
```
$ ln -snvf $(pwd)/hammerspoon/.hammerspoon ~
```
### Notice
- Part of the setting is forked from [awesome-hammerspoon](https://github.com/ashfinal/awesome-hammerspoon).


<a id="tig"></a>
## Tig
### Usage
```
$ ln -snvf $(pwd)/tig/.tigrc ~/.tigrc
```
