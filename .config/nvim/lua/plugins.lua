-- =====================================
--                Plugin (lazy.nvim)
-- =====================================

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
	-- A file explorer tree for neovim written in lua
	{ "nvim-tree/nvim-web-devicons", lazy = true },

	-- A git wrapper
	{ "tpope/vim-fugitive" },
	-- Lightweight and powerful git branch viewer that integrates with fugitive
	{ "rbong/vim-flog" },
	-- Show git diff markers
	{ "airblade/vim-gitgutter" },
	-- Lazygit integration
	{
		"kdheepak/lazygit.nvim",
		lazy = true,
		cmd = {
			"LazyGit",
			"LazyGitConfig",
			"LazyGitCurrentFile",
			"LazyGitFilter",
			"LazyGitFilterCurrentFile",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		keys = {
			{ "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
		},
	},

	{ "nvim-lua/plenary.nvim", lazy = true },

	-- Yazi file manager integration
	{
		"mikavilpas/yazi.nvim",
		event = "VeryLazy",
		dependencies = {
			{ "nvim-lua/plenary.nvim", lazy = true },
		},
		keys = {
			{
				"<leader>tt",
				mode = { "n", "v" },
				"<cmd>Yazi<cr>",
				desc = "Open yazi at the current file",
			},
			{
				"<leader>tw",
				"<cmd>Yazi cwd<cr>",
				desc = "Open yazi in nvim's working directory",
			},
			{
				"<leader>tr",
				"<cmd>Yazi toggle<cr>",
				desc = "Resume the last yazi session",
			},
		},
		---@type YaziConfig | {}
		opts = {
			open_for_directories = true,
			keymaps = {
				show_help = "<f1>",
				open_file_in_vertical_split = "<c-v>",
				open_file_in_horizontal_split = "<c-x>",
				open_file_in_tab = "<c-t>",
				grep_in_directory = "<c-s>",
				replace_in_directory = "<c-g>",
				cycle_open_buffers = "<tab>",
				copy_relative_path_to_selected_files = "<c-y>",
				send_to_quickfix_list = "<c-q>",
			},
		},
		init = function()
			-- netrwを無効化してyaziでディレクトリを開く
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
	},

	-- Find, Filter, Preview, Pick. All lua, all the time
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("telescope").setup({})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
		end,
	},

	-- Searchable cheatsheet for neovim with bundled cheatsheets
	{
		"sudormrfbin/cheatsheet.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"nvim-lua/popup.nvim",
			"nvim-lua/plenary.nvim",
		},
		config = function()
			require("cheatsheet").setup({
				-- bundled cheatsheets（デフォルトとnerd-fontsは無効化、unicodeなどは有効）
				bundled_cheatsheets = {
					disabled = { "default", "nerd-fonts" },
				},
				-- プラグイン固有のcheatsheetを表示
				bundled_plugin_cheatsheets = true,
				-- インストール済みのプラグインのcheatsheetのみ表示
				include_only_installed_plugins = true,
				-- Telescope内のキーマップ
				telescope_mappings = {
					-- Enterでコマンドラインに自動入力（実行はしない）
					["<CR>"] = require("cheatsheet.telescope.actions").select_or_fill_commandline,
					-- Alt-Enterで直接実行
					["<A-CR>"] = require("cheatsheet.telescope.actions").select_or_execute,
					-- Ctrl-Yでコピー
					["<C-Y>"] = require("cheatsheet.telescope.actions").copy_cheat_value,
					-- Ctrl-Eでユーザーcheatsheet編集
					["<C-E>"] = require("cheatsheet.telescope.actions").edit_user_cheatsheet,
				},
			})
		end,
	},

	-- WhichKey: shows available keybindings in popup
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "classic", -- classic | modern | helix
			-- 遅延時間（ミリ秒）：キーを押してからポップアップが表示されるまで
			delay = 200,
			-- 説明がないキーマップを除外（デフォルトのVimキーマップを非表示）
			filter = function(mapping)
				return mapping.desc and mapping.desc ~= ""
			end,
			plugins = {
				marks = true, -- ' と ` でマーク一覧を表示
				registers = true, -- " でレジスタ一覧を表示（ノーマル）、<C-r> で表示（挿入）
				spelling = {
					enabled = true, -- z= でスペル修正候補を表示
					suggestions = 20,
				},
				presets = {
					operators = true, -- d, y などの演算子のヘルプ
					motions = true, -- モーションのヘルプ
					text_objects = true, -- テキストオブジェクトのヘルプ
					windows = true, -- <c-w> のデフォルトバインディング
					nav = true, -- ウィンドウ操作のその他のバインディング
					z = true, -- z から始まるバインディング（fold、spellなど）
					g = false, -- g のデフォルトバインディングを無効化（カスタムのみ表示）
				},
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)

			-- キーマップのグループを登録
			wk.add({
				{ "<leader>f", group = "Find (Telescope)" },
				{ "<leader>l", group = "Git (Lazygit)" },
				{ "<leader>t", group = "File Explorer (Yazi)" },
				{ "g", group = "Go to / LSP / Terminal" },
				{ "s", group = "Window Split" },
				{ "t", group = "Buffer Tab" },
			})
		end,
	},

	{
		"folke/todo-comments.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("todo-comments").setup({
				signs = true,
				sign_priority = 8,
				keywords = {
					FIX = {
						icon = " ",
						color = "error",
						alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
					},
					TODO = { icon = " ", color = "info" },
					HACK = { icon = " ", color = "warning" },
					WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
					PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
					NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				},
				merge_keywords = true,
				highlight = {
					before = "",
					keyword = "wide",
					after = "fg",
					pattern = [[.*<(KEYWORDS)\s*:]],
					comments_only = true,
					max_line_len = 400,
					exclude = {},
				},
				colors = {
					error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
					warning = { "DiagnosticWarning", "WarningMsg", "#FBBF24" },
					info = { "DiagnosticInfo", "#2563EB" },
					hint = { "DiagnosticHint", "#10B981" },
					default = { "Identifier", "#7C3AED" },
				},
			})
		end,
	},

	-- Nvim Treesitter configurations and abstraction layer
	-- NOTE: New API - highlighting via vim.treesitter.start(), parsers via :TSInstall
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			-- Enable treesitter highlighting for all supported filetypes
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- Use treesitter to auto close and auto rename html tag
	{
		"windwp/nvim-ts-autotag",
		config = function()
			require("nvim-ts-autotag").setup({
				opts = {
					enable_close = true,
					enable_rename = true,
					enable_close_on_slash = false,
				},
			})
		end,
	},

	-- autopairs for neovim written by lua
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup({})
		end,
	},

	-- Smart and powerful comment plugin for neovim
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({})
		end,
	},

	-- Improved Yank and Put functionalities for Neovim
	{
		"gbprod/yanky.nvim",
		config = function()
			require("yanky").setup({})
			vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Paste after" })
			vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Paste before" })
			vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Paste after (move cursor)" })
			vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Paste before (move cursor)" })
			vim.keymap.set("n", "<c-n>", "<Plug>(YankyCycleForward)", { desc = "Cycle yank forward" })
			vim.keymap.set("n", "<c-p>", "<Plug>(YankyCycleBackward)", { desc = "Cycle yank backward" })
		end,
	},

	-- Easy resizing of your vim windows
	{ "jimsei/winresizer" },

	-- Markdown preview in browser with synchronised scrolling
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && npx --yes yarn install && curl -fsSL https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.min.js -o _static/mermaid.min.js && cd .. && git update-index --skip-worktree app/_static/mermaid.min.js",
		init = function()
			vim.g.mkdp_filetypes = { "markdown" }
		end,
		config = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_auto_close = 1
			vim.g.mkdp_refresh_slow = 0
			vim.g.mkdp_theme = "dark"
			vim.g.mkdp_combine_preview = 0
		end,
	},

	-- Markdown, HTML, LaTeX, Typst & YAML previewer for Neovim
	{
		"OXY2DEV/markview.nvim",
		lazy = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("markview").setup({
				-- Hybrid mode settings
				hybrid_modes = { "n" },
				-- Callbacks for custom behavior
				callbacks = {
					on_enable = function(_, win)
						vim.wo[win].conceallevel = 2
						vim.wo[win].concealcursor = "c"
					end,
				},
				preview = {
					icon_provider = "mini", -- "mini" or "devicons"
				},
			})
		end,
	},

	-- Quickstart configs for Nvim LSP
	{ "neovim/nvim-lspconfig" },

	-- Easily install and manage LSP servers, DAP servers, linters, and formatters
	-- Mason v2: Organization changed from williamboman to mason-org
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},

	-- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim
	-- Mason v2: Organization changed from williamboman to mason-org
	{
		"mason-org/mason-lspconfig.nvim",
		dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
		config = function()
			-- Configure LSP servers using vim.lsp.config
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			vim.lsp.config("lua_ls", {
				capabilities = capabilities,
			})

			-- Biome for TypeScript/JavaScript (LSP + linter + formatter)
			vim.lsp.config("biome", {
				capabilities = capabilities,
			})

			-- Ruff for Python (LSP + linter + formatter)
			vim.lsp.config("ruff", {
				capabilities = capabilities,
			})

			-- Markdown Oxide for Markdown (LSP)
			-- Only start on markdown files to avoid crashes on unnamed buffers
			vim.lsp.config("markdown_oxide", {
				capabilities = capabilities,
				filetypes = { "markdown" },
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"biome",
					"ruff",
					"markdown_oxide",
				},
				automatic_enable = true,
			})
		end,
	},

	-- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
	-- Note: Python uses ruff, TypeScript uses biome (both have built-in formatting)
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- Lua formatter
					null_ls.builtins.formatting.stylua,
				},
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(ev)
					local client = vim.lsp.get_client_by_id(ev.data.client_id)
					if client == nil then
						return
					end

					if client.supports_method("textDocument/formatting") then
						local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
						vim.api.nvim_clear_autocmds({ group = augroup, buffer = ev.bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = augroup,
							buffer = ev.bufnr,
							callback = function(args)
								vim.lsp.buf.format({
									timeout_ms = 5000,
									async = false,
								})
							end,
						})
					end
				end,
			})
		end,
	},

	{
		"jay-babu/mason-null-ls.nvim",
		dependencies = { "mason-org/mason.nvim", "nvimtools/none-ls.nvim" },
		config = function()
			require("mason-null-ls").setup({
				ensure_installed = {
					-- Lua tools only (Python uses ruff, TypeScript uses biome)
					"luacheck",
					"stylua",
				},
				automatic_setup = true,
				handlers = {},
			})
		end,
	},

	-- improve neovim lsp experience
	{
		"glepnir/lspsaga.nvim",
		branch = "main",
		event = "LspAttach",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("lspsaga").setup({
				lightbulb = {
					sign = false,
				},
			})
			-- Hover（ドキュメント表示）
			vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover documentation" })
			-- Finder（参照・定義検索）
			vim.keymap.set("n", "gr", "<cmd>Lspsaga lsp_finder<CR>", { desc = "Find references" })
			-- Definition（定義へジャンプ）
			vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition" })
			-- Type Definition（型定義へジャンプ）
			vim.keymap.set("n", "gy", "<cmd>Lspsaga goto_type_definition<CR>", { desc = "Type definition" })
			-- Code Action（コードアクション）
			vim.keymap.set("n", "ga", "<cmd>Lspsaga code_action<CR>", { desc = "Code action" })
			-- Rename（リネーム）
			vim.keymap.set("n", "gn", "<cmd>Lspsaga rename<CR>", { desc = "Rename symbol" })
			-- Diagnostics（診断情報）
			vim.keymap.set("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>", { desc = "Show diagnostics" })
			vim.keymap.set("n", "g[", "<cmd>Lspsaga diagnostic_jump_prev<CR>", { desc = "Previous diagnostic" })
			vim.keymap.set("n", "g]", "<cmd>Lspsaga diagnostic_jump_next<CR>", { desc = "Next diagnostic" })
			-- Format（フォーマット）
			vim.keymap.set(
				"n",
				"fm",
				"<cmd>lua vim.lsp.buf.format({ timeout_ms = 5000 })<CR>",
				{ desc = "Format buffer" }
			)
			-- Terminal Toggle（ノーマルモード・ターミナルモード両方で動作）
			vim.keymap.set({ "n", "t" }, "gt", "<cmd>Lspsaga term_toggle<CR>", { desc = "Toggle terminal" })
		end,
	},

	-- A completion plugin for neovim coded in Lua
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-vsnip",
			"hrsh7th/vim-vsnip",
			"onsails/lspkind.nvim",
		},
		config = function()
			local lspkind = require("lspkind")
			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						vim.fn["vsnip#anonymous"](args.body)
					end,
				},
				sources = {
					{ name = "nvim_lsp" },
					{ name = "vsnip" },
					{ name = "buffer" },
					{ name = "path" },
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-l>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
				}),
				experimental = {
					ghost_text = true,
				},
				formatting = {
					format = lspkind.cmp_format({
						mode = "symbol",
						maxwidth = 50,
						ellipsis_char = "...",
					}),
				},
			})

			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "cmp_git" },
				}, {
					{ name = "buffer" },
					{ name = "nvim_lsp" },
				}),
			})

			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- vscode-like pictograms for neovim lsp completion items
	{ "onsails/lspkind.nvim" },

	-- vsnip
	{ "hrsh7th/cmp-vsnip" },
	{ "hrsh7th/vim-vsnip" },

	-- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
		config = function()
			require("noice").setup({
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				presets = {
					bottom_search = false,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
					lsp_doc_border = false,
				},
			})
		end,
	},

	{ "MunifTanjim/nui.nvim", lazy = true },
	{
		"rcarriga/nvim-notify",
		config = function()
			require("notify").setup({
				render = "wrapped-compact",
				background_colour = "#1a1b26",
			})
			vim.keymap.set("n", "<leader>fn", "<Cmd>Telescope notify<CR>")
		end,
	},

	-- Indent guides for Neovim
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		dependencies = { "TheGLander/indent-rainbowline.nvim" },
		config = function()
			local opts = {}
			require("ibl").setup(require("indent-rainbowline").make_opts(opts))
			vim.opt.listchars:append("space:⋅")
			vim.opt.listchars:append("eol:↴")
		end,
	},

	-- Color theme
	{
		"HoNamDuong/hybrid.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("hybrid").setup({
				terminal_colors = true,
				undercurl = true,
				underline = true,
				bold = true,
				italic = {
					strings = false,
					emphasis = true,
					comments = true,
					folds = true,
				},
				strikethrough = true,
				inverse = true,
				transparent = true,
				overrides = function(highlights, colors) end,
			})
		end,
	},

	-- A blazing fast and easy to configure neovim statusline plugin written in pure lua
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					icons_enabled = true,
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
					disabled_filetypes = {},
					always_divide_middle = true,
					globalstatus = false,
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						{
							"filename",
							file_status = true,
							path = 2,
						},
					},
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
				inactive_sections = {
					lualine_a = {},
					lualine_b = {},
					lualine_c = { "filename" },
					lualine_x = { "location" },
					lualine_y = {},
					lualine_z = {},
				},
				tabline = {},
				extensions = {},
			})
		end,
	},

	-- A snazzy bufferline for Neovim
	{
		"akinsho/bufferline.nvim",
		dependencies = "nvim-tree/nvim-web-devicons",
		config = function()
			require("bufferline").setup({})
		end,
	},

	-- avante-status
	{ "takeshid/avante-status.nvim" },

	-- avante.nvim
	{
		"yetone/avante.nvim",
		branch = "main",
		build = "make BUILD_FROM_SOURCE=true",
		lazy = false,
		version = false,
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-tree/nvim-web-devicons",
			"HakonHarnes/img-clip.nvim",
		},
		config = function()
			require("avante_lib").load()
			require("avante").setup({
				provider = "ollama",
				auto_suggestions_provider = "ollama",
				providers = {
					ollama = {
						endpoint = "http://localhost:11434",
						model = "nezahatkorkmaz/deepseek-v3:latest",
						timeout = 30000,
						extra_request_body = {
							options = {
								temperature = 0.6,
								num_ctx = 4096,
							},
						},
					},
				},
				ui = {
					code_action_icon = "", -- 空文字列で非表示
					border = "rounded",
				},
				behaviour = {
					auto_suggestions = false,
					auto_set_highlight_group = true,
					auto_set_keymaps = true,
					auto_apply_diff_after_generation = false,
					support_paste_from_clipboard = false,
					minimize_diff = true,
				},
				mappings = {
					diff = {
						ours = "co",
						theirs = "ct",
						all_theirs = "ca",
						both = "cb",
						cursor = "cc",
						next = "]x",
						prev = "[x",
					},
					suggestion = {
						accept = "<M-l>",
						next = "<M-]>",
						prev = "<M-[>",
						dismiss = "<C-]>",
					},
					jump = {
						next = "]]",
						prev = "[[",
					},
					submit = {
						normal = "<CR>",
						insert = "<C-s>",
					},
					sidebar = {
						apply_all = "A",
						apply_cursor = "a",
						switch_windows = "<Tab>",
						reverse_switch_windows = "<S-Tab>",
					},
				},
				hints = { enabled = true },
				windows = {
					position = "right",
					wrap = true,
					width = 30,
					sidebar_header = {
						enabled = true,
						align = "center",
						rounded = true,
					},
					input = {
						prefix = "> ",
						height = 8,
					},
					edit = {
						border = "rounded",
						start_insert = true,
					},
					ask = {
						floating = false,
						start_insert = true,
						border = "rounded",
						focus_on_apply = "ours",
					},
				},
				highlights = {
					diff = {
						current = "DiffText",
						incoming = "DiffAdd",
					},
				},
			})
		end,
	},

	-- dressing.nvim
	{ "stevearc/dressing.nvim" },

	-- img-clip.nvim
	{ "HakonHarnes/img-clip.nvim" },

	-- Neovim plugin to animate the cursor with a smear effect
	{
		"sphamba/smear-cursor.nvim",
		opts = {
			-- Smear cursor when switching buffers or windows
			smear_between_buffers = true,
			-- Smear cursor when moving within line or to neighbor lines
			smear_between_neighbor_lines = true,
			-- Draw the smear in buffer space instead of screen space when scrolling
			scroll_buffer_space = true,
			-- Smear cursor in insert mode
			smear_insert_mode = true,
		},
	},
}, {
	-- lazy.nvim options
	install = { colorscheme = { "hybrid", "habamax" } },
	checker = { enabled = false },
})

vim.lsp.set_log_level("debug")
