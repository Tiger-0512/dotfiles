local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap


-- NORMAL MODE
-- Move visual line with 'j' and 'k', vice versa
keymap('n', 'k', 'gk', opts)
keymap('n', 'j', 'gj', opts)
keymap('n', 'gk', 'k', opts)
keymap('n', 'gj', 'j', opts)

-- Use enter to create a new line
keymap('n', '<CR>', 'A<CR><ESC>', opts)

-- Move working windows
keymap('n', 'sj', '<C-w>j', vim.tbl_extend('force', opts, { desc = "Move to window below" }))
keymap('n', 'sk', '<C-w>k', vim.tbl_extend('force', opts, { desc = "Move to window above" }))
keymap('n', 'sl', '<C-w>l', vim.tbl_extend('force', opts, { desc = "Move to window right" }))
keymap('n', 'sh', '<C-w>h', vim.tbl_extend('force', opts, { desc = "Move to window left" }))

-- Create new windows
keymap('n', 'ss', ':<C-u>sp<CR><C-w>j', vim.tbl_extend('force', opts, { desc = "Split horizontal" }))
keymap('n', 'sv', ':<C-u>vs<CR><C-w>l', vim.tbl_extend('force', opts, { desc = "Split vertical" }))

-- Move buffers
keymap('n', 'tp', ':bp<CR>', vim.tbl_extend('force', opts, { desc = "Previous buffer" }))
keymap('n', 'tn', ':bn<CR>', vim.tbl_extend('force', opts, { desc = "Next buffer" }))
keymap('n', 'tf', ':bf<CR>', vim.tbl_extend('force', opts, { desc = "First buffer" }))
keymap('n', 'tl', ':bl<CR>', vim.tbl_extend('force', opts, { desc = "Last buffer" }))

-- Highlight a word on the cursor
-- When you cancel highlighting, use ':noh'
keymap('n', '<Space><Space>', [[<cmd>let @/='\<'.expand('<cword>').'\>'<CR>:set hlsearch<CR>]], vim.tbl_extend('force', opts, { desc = "Highlight word under cursor" }))


-- INSERT MODE
keymap('i', '<C-k>', '<Up>'    , opts)
keymap('i', '<C-j>', '<Down>'  , opts)
keymap('i', '<C-h>', '<Left>'  , opts)
keymap('i', '<C-l>', '<Right>' , opts)
-- Go Beggining of the line
keymap('i', '<C-i>', '<C-o>^', opts)
-- Go End of the line
keymap('i', '<C-a>', '<C-o>$', opts)

