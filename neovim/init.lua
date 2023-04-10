-- Leader
vim.g.mapleader = ','

local filetype = require('filetype')

-- =====================================
--                Basic
-- =====================================
--  Visualize tab, space, etc...
vim.opt.list = true
vim.opt.listchars = {
    space='·',
    tab='>·',
    extends='»',
    precedes='«',
    trail='-',
    nbsp='%'
}
vim.opt.termguicolors = true

-- Encoding
vim.opt.encoding = "UTF-8"

-- Line Number
vim.opt.number = true

-- Create new tab under the current tab
vim.opt.splitbelow = true

-- TODO: check
-- " Change colors
-- hi NonText ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
-- hi SpecialKey ctermbg=NONE ctermfg=59 guibg=NONE guifg=NONE
-- filetype plugin indent on

vim.cmd('syntax enable')

-- " Highlight current row
-- autocmd ColorScheme * highlight LineNr ctermfg=12
-- highlight CursorLineNr ctermbg=4 ctermfg=0
-- set cursorline
-- highlight clear CursorLine

-- " Background opacity
-- highlight Normal ctermbg=NONE
-- highlight NonText ctermbg=NONE
-- highlight LineNr ctermbg=NONE
-- highlight Folded ctermbg=NONE
-- highlight EndOfBuffer ctermbg=NONE

-- Indent
-- Default
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
-- Custom
vim.api.nvim_create_augroup('indent_by_filetype', {})
vim.api.nvim_create_autocmd('FileType', {
    group = 'indent_by_filetype',
    pattern = '*',
    callback = function(args) filetype[args.match]() end
})

-- Search options
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Move to up and down rows with 'h' and 'l'
vim.opt.whichwrap = 'b,s,h,l,<,>,[,],~'
-- TODO: check
-- Specify the motion of backspace
vim.opt.backspace = { indent=true, eol=true, start=true }

-- Clipboard
-- TODO: check
vim.opt.clipboard:append{'unnamedplus'}

-- TODO: check
-- Font for gui
vim.opt.guifont = 'FantasqueSansMono Nerd Font:h14'


-- Require
require('keymaps')
require('plugins')


-- Colorscheme
vim.cmd('colorscheme hybrid')

