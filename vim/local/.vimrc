" Invalid the compatibility with vi
set nocompatible
" Setting for using coc with ale
let g:ale_disable_lsp = 1


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
    " " Lightweight and powerful git branch viewer that integrates with fugitive
    " Plug 'rbong/vim-flog'
    " Show git diff markers
    Plug 'airblade/vim-gitgutter'
    " A powerful git log viewer
    Plug 'cohama/agit.vim'

    " " Jump to any location specified by two characters
    " Plug 'justinmk/vim-sneak'
    " Unite and create user interfaces
    Plug 'shougo/unite.vim'
    " Command-line fuzzy finder
    Plug 'junegunn/fzf'
    " Add command for fzf
    Plug 'junegunn/fzf.vim'

    " Auto Bracket
    Plug 'Raimondi/delimitMate'
    " Change Bracket by using shortcuts
    Plug 'tpope/vim-surround'
    " Auto close (X)HTML tags and others'
    " Alternative: https://github.com/windwp/nvim-ts-autotag
    Plug 'alvan/vim-closetag'
    " Use 'gcc' to comment out a line, gc to comment out the target of a motion
    Plug 'tpope/vim-commentary'
    " Logging registers and reusing them
    Plug 'LeafCage/yankround.vim'
    " Easy resizing of your vim windows
    Plug 'jimsei/winresizer'
    " Save files to disk automatically
    Plug '907th/vim-auto-save'

    " Text filtering and alignmen
    Plug 'godlygeek/tabular'
    " Markdown vim mode
    Plug 'plasticboy/vim-markdown'
    " Realtime preview by Vim. (Markdown, reStructuredText, textile)
    Plug 'previm/previm'

    " Nodejs extension host for vim & neovim, load extensions and host language servers
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
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
"               Basic
"=====================================
filetype plugin indent on

set termguicolors
" Color theme
if has('nvim')
    colorscheme hybrid
else
    colorscheme spring-night
endif

" Visualize tab, space, etc...
set list
set listchars=space:·,tab:>·,extends:»,precedes:«,trail:-,nbsp:%
" Change colors
hi NonText ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE

syntax enable
" Fix row number color
autocmd ColorScheme * highlight LineNr ctermfg=239
" Transparent background
hi Normal guibg=NONE ctermbg=NONE

" Specify the motion of backspace
set backspace=indent,eol,start

" Encoding
set encoding=UTF-8

" Line Number
set number

" Indent to space
set expandtab
set smarttab

" Indent
" Default
set autoindent
set shiftwidth=4
set softtabstop=4
set tabstop=4
" Custom
autocmd FileType html  setlocal sw=2 sts=2 ts=2
autocmd FileType css  setlocal sw=2 sts=2 ts=2
autocmd FileType javascript  setlocal sw=2 sts=2 ts=2
autocmd FileType typescript  setlocal sw=2 sts=2 ts=2
autocmd FileType typescriptreact  setlocal sw=2 sts=2 ts=2
autocmd FileType dart  setlocal sw=2 sts=2 ts=2

" Highlight current row
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

" Search options
set hlsearch
set ignorecase
set smartcase

" Move to up and down rows with 'h' and 'l'
set whichwrap=b,s,h,l,<,>,[,],~

" Create new tab under the current tab
set splitbelow

" ***** KEY MAPPING *****
" NORMAL MODE
" Move visual line with 'j' and 'k', vice versa
nnoremap k gk
nnoremap j gj
nnoremap gk k
nnoremap gj j

" Use enter to create a new line
nnoremap <CR> A<CR><ESC>

" Move working windows
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
" Create new windows
nnoremap ss :<C-u>sp<CR><C-w>j
nnoremap sv :<C-u>vs<CR><C-w>l

" Move buffers
nnoremap tp :bp<CR>
nnoremap tn :bn<CR>
nnoremap tf :bf<CR>
nnoremap tl :bl<CR>

" Highlight a word on the cursor
nnoremap <Space><Space> :let @/ = '\<' . expand('<cword>') . '\>'<CR>:set hlsearch<CR>
" When you cansel highlighting, use ':noh'

" INSERT MODE
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
" Go Beggining of the line
inoremap <C-i> <C-o>^
" Go End of the line
inoremap <C-a> <C-o>$

" Visualize the link when using markdown
let g:indentLine_concealcursor = "nc"

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
" Vim settings
else
    " Terminal
    command! T terminal ++rows=20
endif
" Change terminal mode to normal mode in terminal with ESC
tnoremap <C-n><C-m> <C-\><C-n>

" Font for gui
set guifont=FantasqueSansMono\ Nerd\ Font:h14


"=====================================
"               NERDTree
"=====================================
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Show hidden files
let NERDTreeShowHidden = 1

" NERDTree tabs settings
let g:nerdtree_tabs_open_on_console_startup = 1
let g:nerdtree_tabs_focus_on_files = 1

" Exit Vim if NERDTree is the only window left
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
let g:airline_theme='bubblegum'
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1 " You can change to previous tab with :bp and next tab with :bn
let g:airline#extensions#default#layout = [
    \ [ 'a', 'b', 'c'],
    \ [ 'x', 'y', 'z', 'error', 'warning'],
\ ]
" To visualize coc status
set statusline^=%{coc#status()}


"=====================================
"               closetag.vim
"=====================================
let g:closetag_filenames = "*.html,*.jsx,*.tsx,*.vue,*.xhml,*.xml"
let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*tsx'
let g:closetag_filetypes = 'html,xhtml,phtml'
let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx'
let g:closetag_emptyTags_caseSensitive = 1
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ 'typescriptreact': 'jsxRegion,tsxRegion',
    \ 'javascriptreact': 'jsxRegion',
    \ }
let g:closetag_shortcut = '>'
let g:closetag_close_shortcut = '<leader>>'


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
"               Markdown
"=====================================
let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
let g:previm_open_cmd = 'open -a Google\ Chrome'


"=====================================
"               COC
"=====================================
" Installation
let g:coc_global_extensions = [
    \ 'coc-html',
    \ 'coc-css',
    \ 'coc-tsserver',
    \ 'coc-flutter',
    \ 'coc-pyright',
    \ 'coc-go',
    \ 'coc-json'
\ ]
"
nnoremap ,n :CocCommand document.renameCurrentWord<CR>

"=====================================
"               ALE
"=====================================
" Installation
" Flake8: pip install flake8
" Black: pip install black
" Prettier: npm install -g prettier
" Fixjson: npm install -g fixjson
" Docker: npm install -g dockerfile-language-server-nodejs
let g:ale_sign_error = '!!'
let g:ale_sign_warning = '=='
let g:ale_linters = {
    \ 'python': ['flake8'],
    \ 'go': ['gofmt'],
    \ 'javascript': ['eslint'],
    \ 'javascriptreact': ['eslint'],
    \ 'typescript': ['tsserver'],
    \ 'typescriptreact': ['tsserver'],
\ }
let g:ale_fixers = {
    \ '*': ['remove_trailing_lines', 'trim_whitespace'],
    \ 'python': ['black'],
    \ 'go': ['gofmt'],
    \ 'html': ['prettier'],
    \ 'css': ['prettier'],
    \ 'javascript': ['prettier'],
    \ 'javascriptreact': ['prettier'],
    \ 'typescript': ['prettier'],
    \ 'typescriptreact': ['prettier'],
    \ 'json': ['fixjson'],
    \ 'jsonc': ['fixjson']
\ }
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
" let g:ale_fix_on_save = 1
nnoremap ,<Space> :<C-u>ALEFix<CR>


"=====================================
"               FZF
"=====================================
nnoremap ,f :<C-u>Files<CR>
nnoremap ,m :<C-u>History<CR>
command! -bang -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --line-number --no-heading '.shellescape(<q-args>), 0,
    \   fzf#vim#with_preview({'options': '--exact --reverse --delimiter : --nth 3..'}, 'right:50%:wrap'))
nnoremap ,r :<C-u>Rg<CR>


"=====================================
"               yankround
"=====================================
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)


"=====================================
"               auto-save
"=====================================
let g:auto_save = 1
let g:auto_save_write_all_buffers = 1
