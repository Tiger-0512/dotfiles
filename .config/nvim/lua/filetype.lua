local M = {}

local function set_indent(tab_length, is_expandtab)
    vim.bo.expandtab = is_expandtab
    -- if is_expandtab then
    --     vim.bo.expandtab = false
    -- else
    --     vim.bo.expandtab = true
    -- end
    vim.bo.shiftwidth = tab_length
    vim.bo.softtabstop = tab_length
    vim.bo.tabstop = tab_length
end

M.help = function()
    vim.api.nvim_buf_set_keymap(0, 'n', 'q', 'ZZ', { noremap = true })
end

-- TODO: Is setlocal required?
M.html = function()
    set_indent(2, true)
end
M.css = function()
    set_indent(2, true)
end
M.javascript = function()
    set_indent(2, true)
end
M.typescript = function()
    set_indent(2, true)
end
M.typescriptreact = function()
    set_indent(2, true)
end
M.dart = function()
    set_indent(2, true)
end
M.go = function()
    set_indent(4, false)
end

return setmetatable(M, {
    __index = function()
        return function()
            -- print('Unexpected filetype!')
            set_indent(4, true)
        end
    end
})
