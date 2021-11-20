# My Dotfiles (Vim/NeoVim, Zsh, Alacritty, Hammerspoon, Tig)

## Table of Contents
- [Vim/NeoVim](#vim)
- [Zsh](#zsh)
- [Alacritty](#alacritty)
- [Hammerspoon](#hammerspoon)
- [Tig](#tig)
- [Git](#git)


<a id="vim"></a>
## Vim/NeoVim
### Example of Use
Vim
```
$ ln -snvf ./dotfiles/vim/local/.vimrc ~/.vimrc
```
NeoVim
```
$ ln -snvf ./dotfiles/vim/local/.vimrc ~/.config/nvim/init.vim
```
### Notice
- There are two types of `.vimrc` in this repo.<br>
- These `.vimrc` supports both Vim and NeoVim.
    - [For local use](https://github.com/Tiger-0512/dotfiles/blob/main/vim/local/.vimrc)
    - [For remote(docker) use](https://github.com/Tiger-0512/dotfiles/blob/main/vim/remote/.vimrc) (having basic functions only)<br>
- Before use, please install [vim-plug](https://github.com/junegunn/vim-plug).<br>
- If you want to use `coc.nvim`, please execute the below command.
```
$ ln -snvf ./dotfiles/vim/coc/coc-settings.json ~/.config/nvim/coc-settings.json
$ ln -snvf ./dotfiles/vim/coc/coc-settings.json ~/.vim/coc-settings.json
```


<a id="zsh"></a>
## Zsh
### Example of Use
```
$ ln -snvf ./dotfiles/zsh/.zshrc ~/.zshrc
```
### Notice
- Before use, please install [zinit](https://github.com/zdharma/zinit).
- In this setting, I use [aura-theme](https://github.com/daltonmenezes/aura-theme). You can use this theme with [its installation guide](https://github.com/daltonmenezes/aura-theme/tree/main/packages/alacritty).


<a id="alacritty"></a>
## Alacritty
### Example of Use
```
$ ln -snvf ./dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml
```

<a id="hammerspoon"></a>
## Hammerspoon
### Example of Use
```
$ mv ./dotfiles/hammerspoon/.hammerspoon ~/.
```
### Notice
- Part of the setting is forked from [awesome-hammerspoon](https://github.com/ashfinal/awesome-hammerspoon).


<a id="tig"></a>
## Tig
### Example of Use
```
$ ln -snvf ./dotfiles/tig/.tigrc ~/.tigrc
```

<a id="git"></a>
## Git
This is the setting for conventional commits
### Example of Use
```
$ git config --global commit.template ./dotfiles/git/.gitcommit-conventions
```
### Notice
The setting is based on below two rules.
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Contributing to Angular](https://github.com/angular/angular/blob/master/CONTRIBUTING.md)

