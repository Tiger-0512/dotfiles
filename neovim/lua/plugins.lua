-- =====================================
--                Plugin
-- =====================================
vim.cmd('packadd vim-jetpack')
require('jetpack.packer').startup(function(use)
    use { 'tani/vim-jetpack', opt = 1 } -- bootstrap

    -- A file explorer tree for neovim written in lua
    -- https://coralpink.github.io/commentary/neovim/plugin/nvim-tree.html
    use { 'nvim-tree/nvim-web-devicons' }
    use {
        'nvim-tree/nvim-tree.lua',
        requires = { 'nvim-tree/nvim-web-devicons' }
    }
    -- A git wrapper
    use { 'tpope/vim-fugitive' }
    -- Lightweight and powerful git branch viewer that integrates with fugitive
    use { 'rbong/vim-flog' }
    -- Show git diff markers
    use { 'airblade/vim-gitgutter' }

    -- -- Neovim motions on speed
    -- use { 'phaazon/hop.nvim', branch = 'v2' }

    use { 'nvim-lua/plenary.nvim' }
    -- Find, Filter, Preview, Pick. All lua, all the time
    use { 'nvim-telescope/telescope.nvim',
        tag = '0.1.1',
        requires = { 'nvim-lua/plenary.nvim' }
    }
    use {
        "folke/todo-comments.nvim",
        requires = { "nvim-lua/plenary.nvim" },
    }

    -- Nvim Treesitter configurations and abstraction layer
    use {
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }
    -- Use treesitter to auto close and auto rename html tag
    use { 'windwp/nvim-ts-autotag' }
    -- autopairs for neovim written by lua
    use {
        "windwp/nvim-autopairs",
        config = function() require("nvim-autopairs").setup({}) end
    }

    -- Smart and powerful comment plugin for neovim
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup({})
        end
    }
    -- Improved Yank and Put functionalities for Neovim
    use { "gbprod/yanky.nvim" }
    -- Easy resizing of your vim windows
    use { 'jimsei/winresizer' }

    -- markdown preview plugin for (neo)vim
    use { "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" }
    }

    -- Quickstart configs for Nvim LSP
    use { 'neovim/nvim-lspconfig' }
    -- Easily install and manage LSP servers, DAP servers, linters, and formatters
    use {
        "williamboman/mason.nvim",
        run = ":MasonUpdate" -- :MasonUpdate updates registry contents
    }
    -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
    use { 'williamboman/mason-lspconfig.nvim' }
    -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    use { 'jose-elias-alvarez/null-ls.nvim' }
    -- improve neovim lsp experience
    use {
        "glepnir/lspsaga.nvim",
        opt = true,
        branch = "main",
        event = "LspAttach",
        config = function()
            require("lspsaga").setup({})
        end,
        requires = {
            { "nvim-tree/nvim-web-devicons" },
            { "nvim-treesitter/nvim-treesitter" }
        }
    }

    -- A completion plugin for neovim coded in Lua
    use { 'neovim/nvim-lspconfig' }
    use { 'hrsh7th/cmp-nvim-lsp' }
    use { 'hrsh7th/cmp-buffer' }
    use { 'hrsh7th/cmp-path' }
    use { 'hrsh7th/cmp-cmdline' }
    use { 'hrsh7th/nvim-cmp' }
    -- vscode-like pictograms for neovim lsp completion items
    use { 'onsails/lspkind.nvim' }
    -- vsnip
    use { 'hrsh7th/cmp-vsnip' }
    use { 'hrsh7th/vim-vsnip' }

    -- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu
    use({
        "folke/noice.nvim",
        config = function()
            require("noice").setup({
                -- add any options here
            })
        end,
        requires = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        }
    })
    use { 'MunifTanjim/nui.nvim' }
    use { 'rcarriga/nvim-notify' }

    -- Indent guides for Neovim
    use { "lukas-reineke/indent-blankline.nvim" }

    -- Color theme
    use { 'w0ng/vim-hybrid' }
    -- A blazing fast and easy to configure neovim statusline plugin written in pure lua
    use {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('lualine').setup({
                options = {
                    icons_enabled = true,
                    -- theme = 'ayu_dark',
                    component_separators = { left = '', right = '' },
                    section_separators = { left = '', right = '' },
                    disabled_filetypes = {},
                    always_divide_middle = true,
                    globalstatus = false,
                },
                sections = {
                    lualine_a = { 'mode' },
                    lualine_b = { 'branch', 'diff', 'diagnostics' },
                    lualine_c = {
                        {
                            'filename',
                            file_status = true,
                            path = 2
                        }
                    },
                    lualine_x = { 'encoding', 'fileformat', 'filetype' },
                    lualine_y = { 'progress' },
                    lualine_z = { 'location' }
                },
                inactive_sections = {
                    lualine_a = {},
                    lualine_b = {},
                    lualine_c = { 'filename' },
                    lualine_x = { 'location' },
                    lualine_y = {},
                    lualine_z = {}
                },
                tabline = {},
                extensions = {}
            })
        end,
        requires = { { 'nvim-tree/nvim-web-devicons' } }
    }
    -- A snazzy bufferline for Neovim
    use { 'akinsho/bufferline.nvim',
        -- tag = "v3.*",
        config = function()
            require("bufferline").setup({})
        end,
        requires = 'nvim-tree/nvim-web-devicons',
    }
end)


-- =====================================
--               nvim-tree
-- =====================================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('nvim-tree').setup({
    sort_by = "case_sensitive",
    view = {
        width = '20%',
        side = 'left',
        -- signcolumn = 'no',
    },
    filters = {
        dotfiles = false, -- Show hidden files
    },
    renderer = {
        group_empty = true,
        highlight_git = true,
        highlight_opened_files = 'name',
        icons = {
            glyphs = {
                git = {
                    unstaged = "✗",
                    staged = "✓",
                    unmerged = "",
                    renamed = "➜",
                    untracked = "★",
                    deleted = "",
                    ignored = "◌",
                },
            },
        },
    },
})

vim.keymap.set('n', '<leader>t', vim.cmd.NvimTreeToggle)


-- =====================================
--               telescope.nvim
-- =====================================
require('telescope').setup({})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {}) -- TODO: check
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


-- =====================================
--                nvim-treesitter
-- =====================================
require('nvim-treesitter.configs').setup {
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


-- =====================================
--                yanky
-- =====================================
require("yanky").setup({})
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
-- Yank-ring
vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)")


-- =====================================
--                mason
-- =====================================
local on_attach = function(client, bufnr)
    -- Default keybindings
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

require('mason').setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})
local mason_package = require("mason-core.package")
local mason_registry = require("mason-registry")

local nvim_lsp = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')
require("mason-lspconfig").setup_handlers {
    function(server_name) -- default handler (optional)
        require("lspconfig")[server_name].setup {
            on_attach = on_attach,
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        }
    end,
}

local null_ls = require("null-ls")
local null_sources = {}

for _, package in ipairs(mason_registry.get_installed_packages()) do
    local package_categories = package.spec.categories[1]
    if package_categories == mason_package.Cat.Formatter then
        table.insert(null_sources, null_ls.builtins.formatting[package.name])
    end
    if package_categories == mason_package.Cat.Linter then
        table.insert(null_sources, null_ls.builtins.diagnostics[package.name])
    end
end

null_ls.setup({
    sources = null_sources,
})


-- =====================================
--                lspsaga
-- =====================================
-- TODO: setup lspsaga
vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
vim.keymap.set('n', 'gr', '<cmd>Lspsaga lsp_finder<CR>')
vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>")
vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>")
vim.keymap.set("n", "gn", "<cmd>Lspsaga rename<CR>")
vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>")
vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_next<CR>")
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
vim.keymap.set({ "n", "t" }, "<A-d>", "<cmd>Lspsaga term_toggle<CR>")


-- =====================================
--                cmp
-- =====================================
local lspkind = require('lspkind')
local cmp = require('cmp')

cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    sources = {
        { name = "nvim_lsp" },
        { name = 'vsnip' }, -- For vsnip users.
        { name = "buffer" },
        { name = "path" },
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(), --Ctrl+p で補完欄を一つ上に移動
        ["<C-n>"] = cmp.mapping.select_next_item(), --Ctrl+n で補完欄を一つ下に移動
        ['<C-l>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ["<C-y>"] = cmp.mapping.confirm({ select = true }), --Ctrl+y で補完を選択確定
    }),
    experimental = {
        ghost_text = false,
    },
    -- Lspkind(アイコン)を設定
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol',       -- show only symbol annotations
            maxwidth = 50,         -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
        })
    }
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


-- =====================================
--                todo-comments
-- =====================================
require("todo-comments").setup {
    signs = true,      -- show icons in the signs column
    sign_priority = 8, -- sign priority
    keywords = {
        FIX = {
            icon = " ",                              -- icon used for the sign, and in search results
            color = "error",                            -- can be a hex color, or a named color (see below)
            alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    },
    merge_keywords = true,               -- when true, custom keywords will be merged with the defaults
    highlight = {
        before = "",                     -- "fg" or "bg" or empty
        keyword = "wide",                -- "fg", "bg", "wide" or empty. (wide is the same as bg, but will also highlight surrounding characters)
        after = "fg",                    -- "fg" or "bg" or empty
        pattern = [[.*<(KEYWORDS)\s*:]], -- pattern or table of patterns, used for highlightng (vim regex)
        comments_only = true,            -- uses treesitter to match keywords in comments only
        max_line_len = 400,              -- ignore lines longer than this
        exclude = {},                    -- list of file types to exclude highlighting
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


-- =====================================
--                indent-blankline
-- =====================================
vim.opt.listchars:append "space:⋅"
vim.opt.listchars:append "eol:↴"

require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
}


-- =====================================
--                lualine.nvim
-- =====================================
-- require('lualine.nvim').setup ({
--     options = {
--         icons_enabled = true,
--         theme = 'ayu_dark',
--         component_separators = { left = '', right = '' },
--         section_separators = { left = '', right = '' },
--         disabled_filetypes = {},
--         always_divide_middle = true,
--         globalstatus = false,
--     },
--     sections = {
--         lualine_a = { 'mode' },
--         lualine_b = { 'branch', 'diff', 'diagnostics' },
--         lualine_c = {
--             {
--                 'filename',
--                 file_status = true,
--                 path = 2
--             }
--         },
--         lualine_x = { 'encoding', 'fileformat', 'filetype' },
--         lualine_y = { 'progress' },
--         lualine_z = { 'location' }
--     },
--     inactive_sections = {
--         lualine_a = {},
--         lualine_b = {},
--         lualine_c = { 'filename' },
--         lualine_x = { 'location' },
--         lualine_y = {},
--         lualine_z = {}
--     },
--     tabline = {},
--     extensions = {}
-- })


-- =====================================
--                noice
-- =====================================
require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})
