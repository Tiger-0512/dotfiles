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
keymap('n', 'sj', '<C-w>j', opts)
keymap('n', 'sk', '<C-w>k', opts)
keymap('n', 'sl', '<C-w>l', opts)
keymap('n', 'sh', '<C-w>h', opts)

-- Create new windows
keymap('n', 'ss', ':<C-u>sp<CR><C-w>j', opts)
keymap('n', 'sv', ':<C-u>vs<CR><C-w>l', opts)

-- Move buffers
keymap('n', 'tp', ':bp<CR>', opts)
keymap('n', 'tn', ':bn<CR>', opts)
keymap('n', 'tf', ':bf<CR>', opts)
keymap('n', 'tl', ':bl<CR>', opts)

-- Highlight a word on the cursor
-- When you cansel highlighting, use ':noh'
-- TODO: check: escape sequence
keymap('n', '<Space><Space>', ":let @/ = < . expand('<cword>') . ><CR>:set hlsearch<CR>", opts)


-- INSERT MODE
keymap('i', '<C-k>', '<Up>'    , opts)
keymap('i', '<C-j>', '<Down>'  , opts)
keymap('i', '<C-h>', '<Left>'  , opts)
keymap('i', '<C-l>', '<Right>' , opts)
-- Go Beggining of the line
keymap('i', '<C-i>', '<C-o>^', opts)
-- Go End of the line
keymap('i', '<C-a>', '<C-o>$', opts)

