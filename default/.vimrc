"=====================================
"               Plugin
"=====================================
call plug#begin()
    " A file system explorer for the Vim editor
    Plug 'preservim/nerdtree'

    " A plugin of NERDTree showing git status flags
    Plug 'Xuyuanp/nerdtree-git-plugin'

    " Fonts with a high number of glyphs
    Plug 'ryanoasis/vim-devicons'

    " Use gcc to comment out a line, gc to comment out the target of a motion
    Plug 'tpope/vim-commentary'
call plug#end()


"=====================================
"               Basic
"=====================================
" Encoding
set encoding=UTF-8

" Line number
set number

" Indent
set autoindent

set shiftwidth=4
set softtabstop=4
set tabstop=4

" Highlight current row
autocmd ColorScheme * highlight LineNr ctermfg=12
highlight CursorLineNr ctermbg=4 ctermfg=0
set cursorline
highlight clear CursorLine

" Search option
set hlsearch
set ignorecase
set smartcase


"=====================================
"               NERDTree
"=====================================
nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Start NERDTree. If a file is specified, move the cursor to its window
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * NERDTree | if argc() > 0 || exists("s:std_in") | wincmd p | endif

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif


"=====================================
"               Filetype
"=====================================
filetype plugin indent on
