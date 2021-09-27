" Invalid the compatibility with vi
set nocompatible


"=====================================
"               Plugin
"=====================================
call plug#begin()
    " A file system explorer for the Vim editor
    Plug 'preservim/nerdtree'
    " Make NERDTree feel like a true panel, independent of tabs
    Plug 'jistr/vim-nerdtree-tabs'

    " A plugin of NERDTree showing git status flags
    Plug 'Xuyuanp/nerdtree-git-plugin'
    " A git wrapper
    Plug 'tpope/vim-fugitive'
    " Show git diff markers
    Plug 'airblade/vim-gitgutter'
    " Gitk for vim
    Plug 'gregsexton/gitv'

    " Jump to any location specified by two characters
    Plug 'justinmk/vim-sneak'
    " Unite and create user interfaces
    Plug 'shougo/unite.vim'
    " Command-line fuzzy finder
    Plug 'junegunn/fzf'
    " Add command for fzf
    Plug 'junegunn/fzf.vim'
    " Use RipGrep in Vim and display results in a quickfix list
    " Plug 'jremmen/vim-ripgrep'

    " Auto Bracket
    Plug 'Raimondi/delimitMate'
    " Change Bracket by using shortcuts
    Plug 'tpope/vim-surround'
    " Use 'gcc' to comment out a line, gc to comment out the target of a motion
    Plug 'tpope/vim-commentary'

    " Solid language pack
    Plug 'sheerun/vim-polyglot'
    " Linter
    Plug 'dense-analysis/ale'

    " Fonts with a high number of glyphs
    Plug 'ryanoasis/vim-devicons'
    " Visualize indent/space
    Plug 'yggdroot/indentline'
    " Rainbow parentheses
    Plug 'luochen1990/rainbow'
    " Color theme
    Plug 'ulwlu/elly.vim'
    " Color theme
    Plug 'w0ng/vim-hybrid'
    " Color theme sets
    Plug 'flazz/vim-colorschemes'
    " Unite for color scheme
    Plug 'ujihisa/unite-colorscheme'
    " Lean & mean status/tabline
    Plug 'vim-airline/vim-airline'
    " vim-airline theme
    Plug 'vim-airline/vim-airline-themes'

call plug#end()


"=====================================
"               Filetype
"=====================================
filetype plugin indent on


"=====================================
"               Basic
"=====================================
syntax enable
" Color theme
if has('nvim')
    colorscheme hybrid
else
    colorscheme elly
endif

" Specify the motion of Backspace
set backspace=indent,eol,start

" Encoding
set encoding=UTF-8

" Line Number
set number

" Indent to Space
set expandtab
set smarttab

" Indent
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4

autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab smarttab

" Highlight Current Row
autocmd ColorScheme * highlight LineNr ctermfg=12
highlight CursorLineNr ctermbg=4 ctermfg=0
set cursorline
highlight clear CursorLine

" Background opacity
highlight Normal ctermbg=NONE
highlight NonText ctermbg=NONE
highlight LineNr ctermbg=NONE
highlight Folded ctermbg=NONE
highlight EndOfBuffer ctermbg=NONE

" Search option
set hlsearch
set ignorecase
set smartcase

" Move to up and down rows with 'h' and 'l'
set whichwrap=b,s,h,l,<,>,[,],~

" Create the new tab under the current tab
set splitbelow

" Key Mapping
" Normal Mode
" Move Visual Line with 'j' and 'k', Vice Versa
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" Use Enter
nnoremap <CR> A<CR><ESC>

" Move working window
nnoremap th :tabp<CR>
nnoremap tl :tabn<CR>
nnoremap tn :tabnew<CR>

" Highlight the word on the cursor
nnoremap <silent> <Space><Space> :let @/ = '\<' . expand('<cword>') . '\>'<CR>:set hlsearch<CR>
" Cansel Highlighting
nnoremap  <CS-h> :<C-u>nohlsearch<cr><Esc>

" Insert Mode
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
" Go Beggining of a Line
inoremap <C-i> <C-o>^
" Go End of a Line
inoremap <C-a> <C-o>$

" Visualize tab, space, etc...
set list
set listchars=space:·,tab:>·,extends:»,precedes:«
" Change colors
hi NonText    ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE

" Font for gui
set guifont=FantasqueSansMono\ Nerd\ Font:h14

" Neovim settings
if has('nvim')
    " Clipboard to neovim
    nnoremap <D-v> "*p
    " Neovim to clipboard
    set clipboard+=unnamedplus

    " Terminal
    " Create terminal window below with T
    command! -nargs=* T split | wincmd j | resize 20 | terminal <args>
    " Start terminal with insert mode
    autocmd TermOpen * startinsert
    " Change terminal mode to normal mode in terminal with ESC
    tnoremap <C-n><C-m> <C-\><C-n>
endif


"=====================================
"               NERDTree
"=====================================
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Show Hidden Files
let NERDTreeShowHidden = 1

" NERDTree Tabs Settings
let g:nerdtree_tabs_open_on_console_startup = 1
let g:nerdtree_tabs_focus_on_files = 1

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" Don't open NERDTree when open file directly with vim
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

let g:NERDTreeGitStatusIndicatorMapCustom = {
    \ 'Modified'  :'✹',
    \ 'Staged'    :'✚',
    \ 'Untracked' :'✭',
    \ 'Renamed'   :'➜',
    \ 'Unmerged'  :'═',
    \ 'Deleted'   :'✖',
    \ 'Dirty'     :'✗',
    \ 'Ignored'   :'☒',
    \ 'Clean'     :'✔︎',
    \ 'Unknown'   :'?',
\ }


"=====================================
"               vim-airline
"=====================================
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='bubblegum'
let g:airline_powerline_fonts = 1


"=====================================
"               indentLine
"=====================================
let g:indentLine_color_term = 239
let g:indentLine_char_list = ['|', '¦', '┆', '┊']


"=====================================
"               rainbow
"=====================================
let g:rainbow_active = 1
let g:rainbow_conf = {
    \ 'separately': {
        \ 'nerdtree': 0,
    \ }
\ }


"=====================================
"               ALE
"=====================================
let g:ale_linters = {
    \ 'python': ['flake8']
\ }
let g:ale_fixers = {
    \ 'python': ['black'],
\ }
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_fix_on_save = 1


"=====================================
"               FZF
"=====================================
nnoremap ,f :<C-u>Files<CR>
nnoremap ,m :<C-u>History<CR>
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --line-number --no-heading '.shellescape(<q-args>), 0,
    \   fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..'}, 'right:50%:wrap'))
