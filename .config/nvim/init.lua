-- Leader
vim.g.mapleader = ","

local filetype = require("filetype")

-- =====================================
--                Basic
-- =====================================
--  Visualize tab, space, etc...
vim.opt.list = true
vim.opt.listchars = {
	space = "·",
	tab = ">·",
	extends = "»",
	precedes = "«",
	trail = "-",
	nbsp = "%",
}
vim.opt.termguicolors = true

-- Encoding
vim.opt.encoding = "UTF-8"

-- Line Number
vim.opt.number = true

-- Create new tab under the current tab
vim.opt.splitbelow = true

vim.cmd("syntax enable")

-- " Highlight current row
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		vim.cmd("highlight LineNr ctermfg=12")
	end,
})
vim.cmd([[
	highlight CursorLineNr ctermbg=4 ctermfg=0
]])
vim.opt.cursorline = true
vim.cmd([[
	highlight clear CursorLine
]])

-- Background opacity
vim.cmd([[
	highlight Normal guibg=none
	highlight NonText guibg=none
	highlight Normal ctermbg=none
	highlight NonText ctermbg=none
	highlight NormalNC guibg=none
	highlight NormalSB guibg=none
]])

-- Indent
-- Default
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
-- Custom
vim.api.nvim_create_augroup("indent_by_filetype", {})
vim.api.nvim_create_autocmd("FileType", {
	group = "indent_by_filetype",
	pattern = "*",
	callback = function(args)
		filetype[args.match]()
	end,
})

-- Auto reload files when changed externally
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "WinEnter", "CursorHold", "CursorHoldI", "TermLeave" }, {
	pattern = "*",
	callback = function()
		if vim.fn.mode() ~= "c" and vim.bo.buftype == "" then
			vim.cmd("checktime")
		end
	end,
})

-- Search options
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Move to up and down rows with 'h' and 'l'
vim.opt.whichwrap = "b,s,h,l,<,>,[,],~"

-- Clipboard
vim.opt.clipboard:append({ "unnamedplus" })

-- Font for gui
vim.opt.guifont = "Source Han Code JP"

-- Require
require("keymaps")
require("plugins")

-- Colorscheme
vim.cmd("colorscheme hybrid")
