" Invalid the compatibility with vi
set nocompatible
" Setting for using coc with ale
let g:ale_disable_lsp = 1


"=====================================
"               Plugin
"=====================================
call plug#begin()
    " General purpose asynchronous tree viewer written in Pure Vim script
    Plug 'lambdalisue/fern.vim', { 'branch': 'main' }
    " Make fern.vim as a default file explorer instead of Netrw
    Plug 'lambdalisue/fern-hijack.vim'

    " Add Git status badge integration on file:// scheme on fern.vim
    Plug 'lambdalisue/fern-git-status.vim'
    " A git wrapper
    Plug 'tpope/vim-fugitive'
    " Lightweight and powerful git branch viewer that integrates with fugitive
    Plug 'rbong/vim-flog'
    " Show git diff markers
    Plug 'airblade/vim-gitgutter'
    " " A powerful git log viewer
    " Plug 'cohama/agit.vim'

    " Vim motions on speed
    Plug 'easymotion/vim-easymotion'
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
    " autopairs for neovim written by lua
    " Alternative: https://github.com/windwp/nvim-ts-autotag
    Plug 'windwp/nvim-ts-autotag'
    Plug 'windwp/nvim-autopairs'

    " Use 'gcc' to comment out a line, gc to comment out the target of a motion
    Plug 'tpope/vim-commentary'
    " Logging registers and reusing them
    Plug 'LeafCage/yankround.vim'
    " Easy resizing of your vim windows
    Plug 'jimsei/winresizer'

    " Text filtering and alignment
    Plug 'godlygeek/tabular'
    " Markdown vim mode
    Plug 'plasticboy/vim-markdown'
    " Realtime preview by Vim. (Markdown, reStructuredText, textile)
    Plug 'previm/previm'

    " Quickstart configs for Nvim LSP
    Plug 'neovim/nvim-lspconfig'
    " Portable package manager for Neovim that runs everywhere Neovim runs
    Plug 'williamboman/mason.nvim'
    " Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
    Plug 'williamboman/mason-lspconfig.nvim'
    " Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    Plug 'jose-elias-alvarez/null-ls.nvim'
    " A light-weight lsp plugin based on neovim built-in lsp with highly a performant UI
    Plug 'glepnir/lspsaga.nvim'

    " A completion plugin for neovim coded in Lua
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'onsails/lspkind.nvim'

    " vsnip
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'hrsh7th/vim-vsnip'

    " " Solid language pack
    " Plug 'sheerun/vim-polyglot'
    " Nvim Treesitter configurations and abstraction layer
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

    " plenary: full; complete; entire; absolute; unqualified. All the lua functions I don't want to write twice
    Plug 'nvim-lua/plenary.nvim'
    " Highlight, list and search todo comments in your projects
    Plug 'folke/todo-comments.nvim'

    " " Fonts with a high number of glyphs
    " Plug 'ryanoasis/vim-devicons'
    " Fundemental plugin to handle Nerd Fonts in Vim
    Plug 'lambdalisue/nerdfont.vim'
    " fern.vim plugin which add file type icon through nerdfont.vim
    Plug 'lambdalisue/fern-renderer-nerdfont.vim'
    " An universal palette for Nerd Fonts
    Plug 'lambdalisue/glyph-palette.vim'
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
    " Plug 'kyazdani42/nvim-web-devicons'
    " A blazing fast and easy to configure neovim statusline plugin written in pure lua
    Plug 'nvim-lualine/lualine.nvim'
    " A snazzy bufferline for Neovim
    Plug 'akinsho/bufferline.nvim'

"     " Embed Neovim in Chrome, Firefox, Thunderbird & others.
"     Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
call plug#end()


"=====================================
"               Basic
"=====================================
" Visualize tab, space, etc...
set list
set listchars=space:·,tab:>·,extends:»,precedes:«,trail:-,nbsp:%
" Change colors
hi NonText ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
filetype plugin indent on

" Color theme
if has('nvim')
    set termguicolors
    colorscheme hybrid
    " colorscheme elly
else
    colorscheme Atelier_CaveDark

endif

syntax enable
" Fix row number color
autocmd ColorScheme * highlight LineNr ctermfg=239
" Transparent background
hi Normal guibg=NONE ctermbg=NONE

" Specify the motion of backspace
set backspace=indent,eol,start

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
augroup vimrc
    autocmd!
    autocmd FileType html  setlocal sw=2 sts=2 ts=2
    autocmd FileType css  setlocal sw=2 sts=2 ts=2
    autocmd FileType javascript  setlocal sw=2 sts=2 ts=2
    autocmd FileType typescript  setlocal sw=2 sts=2 ts=2
    autocmd FileType typescriptreact  setlocal sw=2 sts=2 ts=2
    autocmd FileType dart  setlocal sw=2 sts=2 ts=2
augroup END

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

set number
set encoding=UTF-8

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
"              fern
"=====================================
" Show/Hide file tree
nnoremap <C-t> :Fern . -reveal=% -drawer -toggle -width=40<CR>

" Show hidden files
let g:fern#default_hidden=1

" Use nerdfont
let g:fern#renderer = 'nerdfont'
" Graph patette settings
augroup my-glyph-palette
  autocmd! *
  autocmd FileType fern call glyph_palette#apply()
augroup END


"=====================================
"              gitgutter
"=====================================
" Move to previous change by g]
nnoremap g] :GitGutterPrevHunk<CR>
" Move to next change by g[
nnoremap g[ :GitGutterNextHunk<CR>
" Highlight git diff by gh
nnoremap gh :GitGutterLineHighlightsToggle<CR>
" Show git diff in current line by gp
nnoremap gp :GitGutterPreviewHunk<CR>
" Change color of the symbols
highlight GitGutterAdd ctermfg=green
highlight GitGutterChange ctermfg=blue
highlight GitGutterDelete ctermfg=red

"" Set update time (default: 4000ms)
set updatetime=250


""=====================================
""               lualine.nvim
""=====================================
lua <<EOF
require('lualine').setup {
    options = {
        icons_enabled = true,
        theme = 'ayu_dark',
        component_separators = {left = '', right = ''},
        section_separators = {left = '', right = ''},
        disabled_filetypes = {},
        always_divide_middle = true,
        globalstatus = false,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
            {
                'filename',
                file_status = true,
                path = 2
            }
        },
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    extensions = {}
}
EOF


"=====================================
"               bufferline.nvim
"=====================================
lua << EOF
require("bufferline").setup{}
EOF


"=====================================
"               nvim-autopairs
"=====================================
lua << EOF
require("nvim-autopairs").setup {}
EOF


""=====================================
""               closetag.vim
""=====================================
"let g:closetag_filenames = "*.html,*.js,*.jsx,*.tsx,*.vue,*.xhml,*.xml"
"let g:closetag_xhtml_filenames = '*.xhtml,*.jsx,*tsx'
"let g:closetag_filetypes = 'html,xhtml,phtml'
"let g:closetag_xhtml_filetypes = 'xhtml,jsx,tsx'
"let g:closetag_emptyTags_caseSensitive = 1
"let g:closetag_regions = {
"    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
"    \ 'javascript.jsx': 'jsxRegion',
"    \ 'typescriptreact': 'jsxRegion,tsxRegion',
"    \ 'javascriptreact': 'jsxRegion',
"    \ }
"let g:closetag_shortcut = '>'
"let g:closetag_close_shortcut = '<leader>>'


"=====================================
"               indentLine
"=====================================
let g:indentLine_color_term = 239
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" Visualize the link when using markdown
let g:indentLine_concealcursor = "nc"


""=====================================
""               rainbow
""=====================================
"let g:rainbow_active = 1
"let g:rainbow_conf = {
"    \ 'separately': {
"        \ 'fern': 0,
"    \ }
"\ }


"=====================================
"               Markdown
"=====================================
let g:vim_markdown_folding_disabled = 1
let g:previm_enable_realtime = 1
let g:previm_open_cmd = 'open -a Google\ Chrome'


"=====================================
"               mason
"=====================================
lua << EOF
local on_attach = function(client, bufnr)
  -- LSPが持つフォーマット機能を無効化する
  -- →例えばtsserverはデフォルトでフォーマット機能を提供しますが、利用したくない場合はコメントアウトを解除してください
  --client.server_capabilities.documentFormattingProvider = false

  -- 下記ではデフォルトのキーバインドを設定しています
  -- ほかのLSPプラグインを使う場合（例：Lspsaga）は必要ないこともあります
  local set = vim.keymap.set
  set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
  set("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
  set("n", "<C-m>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
  set("n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<CR>")
  set("n", "rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
  set("n", "ma", "<cmd>lua vim.lsp.buf.code_action()<CR>")
  set("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
  set("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>")
  set("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>")
  set("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>")
  set("n", "fm", "<cmd>lua vim.lsp.buf.format()<CR>")
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local mason = require('mason')
-- local mason_package = require("mason-core.package")
-- local mason_registry = require("mason-registry")

-- local null_ls = require("null-ls")

mason.setup({
  ui = {
      icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
      }
  }
})

local nvim_lsp = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')
require("mason-lspconfig").setup_handlers {
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {
      on_attach = on_attach, --keyバインドなどの設定を登録
      capabilities = capabilities, --cmpを連携
    }
  end,
}

-- local null_sources = {}
-- 
-- for _, package in ipairs(mason_registry.get_installed_packages()) do
--         local package_categories = package.spec.categories[1]
--         if package_categories == mason_package.Cat.Formatter then
--                 table.insert(null_sources, null_ls.builtins.formatting[package.name])
--         end
--         if package_categories == mason_package.Cat.Linter then
--                 table.insert(null_sources, null_ls.builtins.diagnostics[package.name])
--         end
-- end
-- 
-- null_ls.setup({
--         sources = null_sources,
-- })
EOF


"=====================================
"               lspsaga
"=====================================
lua << EOF
-- require("lspsaga").init_lsp_saga({
--   border_style = "single",
--   symbol_in_winbar = {
--     enable = true,
--   },
--   code_action_lightbulb = {
--     enable = true,
--   },
--   show_outline = {
--     win_width = 50,
--     auto_preview = false,
--   },
-- })
-- 
-- vim.keymap.set("n", "K",  "<cmd>Lspsaga hover_doc<CR>")
-- vim.keymap.set('n', 'gr', '<cmd>Lspsaga lsp_finder<CR>')
-- vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
-- vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>")
-- vim.keymap.set("n", "gn", "<cmd>Lspsaga rename<CR>")
-- vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
-- vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
-- vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
-- vim.keymap.set({"n", "t"}, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")
EOF

"=====================================
"               cmp
"=====================================
lua << EOF
local lspkind = require 'lspkind'

local cmp = require'cmp'

cmp.setup({
snippet = {
  -- REQUIRED - you must specify a snippet engine
  expand = function(args)
    vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
    -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
    -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
  end,
},
window = {
  -- completion = cmp.config.window.bordered(),
  -- documentation = cmp.config.window.bordered(),
},
mapping = cmp.mapping.preset.insert({
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
}),
sources = cmp.config.sources({
  { name = 'nvim_lsp' },
  { name = 'vsnip' }, -- For vsnip users.
  -- { name = 'luasnip' }, -- For luasnip users.
  -- { name = 'ultisnips' }, -- For ultisnips users.
  -- { name = 'snippy' }, -- For snippy users.
}, {
  { name = 'buffer' },
})
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
sources = cmp.config.sources({
  { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
}, {
  { name = 'buffer' },
})
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
mapping = cmp.mapping.preset.cmdline(),
sources = {
  { name = 'buffer' }
}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
mapping = cmp.mapping.preset.cmdline(),
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
})
})
EOF

"=====================================
"               null-ls
"=====================================
lua << EOF
local null_ls = require("null-ls")
-- local status, null_ls = pcall(require, "null-ls")
-- if (not status) then return end
null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.eslint.with({ 
        prefer_local = "node_modules/.bin",
    }),
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.formatting.black,
    },
    debug = false,
})
EOF


"=====================================
"               FZF
"=====================================
nnoremap ,f :<C-u>Files<CR>
nnoremap ,h :<C-u>History<CR>
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
"               easymotion
"=====================================
" Disable default mappings
let g:EasyMotion_do_mapping = 0

let mapleader = ","
map <Leader> <Plug>(easymotion-prefix)

" Move to line
map <Leader>l <Plug>(easymotion-bd-jk)
nmap <Leader>l <Plug>(easymotion-overwin-line)
" Move to word
map  <Leader>w <Plug>(easymotion-bd-w)
nmap <Leader>w <Plug>(easymotion-overwin-w)

map  <Leader> <Plug>(easymotion-prefix)
nmap m <Plug>(easymotion-s2)
xmap m <Plug>(easymotion-s2)


"=====================================
"               Treesitter
"=====================================
lua <<EOF
require'nvim-treesitter.configs'.setup {
    ensure_installed = {
        'bash',
        'cmake',
        'c',
        'cpp',
        'comment',
        'dockerfile',
        'go',
        'gomod',
        'graphql',
        'html',
        'javascript',
        'jsdoc',
        'json',
        'jsonc',
        'lua',
        'python',
        'regex',
        'rst',
        'rust',
        'scss',
        'toml',
        'tsx',
        'typescript',
        'vue',
        'vim',
        'markdown',
    },
    highlight = {
        enable = true,
        disable = {},
    },
    autotag = {
      enable = true,
    }
}
EOF


"=====================================
"               todo-comments
"=====================================
lua << EOF
require("todo-comments").setup {
    signs = true, -- show icons in the signs column
    sign_priority = 8, -- sign priority
    keywords = {
        FIX = {
            icon = " ", -- icon used for the sign, and in search results
            color = "error", -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    },
    merge_keywords = true, -- when true, custom keywords will be merged with the defaults
    highlight = {
        before = "", -- "fg" or "bg" or empty
        keyword = "wide", -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
        after = "fg", -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
        comments_only = true, -- uses treesitter to match keywords in comments only
        max_line_len = 400, -- ignore lines longer than this
        exclude = {}, -- list of file types to exclude highlighting
    },
    -- list of named colors where we try to extract the guifg from the
    -- list of hilight groups or use the hex color if hl not found as a fallback
    colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
    },
}
EOF


""=====================================
""               Firenvim
""=====================================
"let g:firenvim_config = {
"    \ 'localSettings': {
"        \ '.*': {
"            \ 'selector': 'textarea, div[role="textbox"]',
"            \ 'priority': 0,
"        \ },
"        \ '.*aws.amazon.com.*': {
"            \ 'selector': '',
"            \ 'priority': 1,
"        \ }
"    \ }
"\ }


"=====================================
"               Neovide
"=====================================
let g:neovide_transparency=0.9
set guifont="Hack Nerd Font Mono"
