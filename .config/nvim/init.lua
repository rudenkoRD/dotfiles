-- always set leader first!
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-------------------------------------------------------------------------------
--
-- preferences
--
-------------------------------------------------------------------------------
local opt = vim.opt

opt.termguicolors = true
-- never ever folding
opt.foldenable = false
opt.foldmethod = "manual"
opt.foldlevelstart = 99
-- very basic "continue indent" mode (autoindent) is always on in neovim
-- could try smartindent/cindent, but meh.
-- vim.opt.cindent = true
-- XXX
-- vim.opt.cmdheight = 2
-- vim.opt.completeopt = 'menuone,noinsert,noselect'
-- not setting updatedtime because I use K to manually trigger hover effects
-- and lowering it also changes how frequently files are written to swap.
-- vim.opt.updatetime = 300
-- if key combos seem to be "lagging"
-- http://stackoverflow.com/questions/2158516/delay-before-o-opens-a-new-line
-- vim.opt.timeoutlen = 300
-- keep more context on screen while scrolling
opt.scrolloff = 2
-- never show me line breaks if they're not there
opt.wrap = false
-- always draw sign column. prevents buffer moving when adding/deleting sign
opt.signcolumn = "yes"
-- sweet sweet relative line numbers
opt.relativenumber = true
-- and show the absolute line number for the current line
opt.number = true
-- keep current content top + left when splitting
opt.splitright = true
opt.splitbelow = true
-- infinite undo!
-- NOTE: ends up in ~/.local/state/nvim/undo/
opt.undofile = true
--" Decent wildmenu
-- in completion, when there is more than one match,
-- list all matches, and only complete to longest common match
opt.wildmode = "list:longest"
-- when opening a file with a command (like :e),
-- don't suggest files like there:
opt.wildignore = ".hg,.svn,*~,*.png,*.jpg,*.gif,*.min.js,*.swp,*.o,vendor,dist,_site"
-- tabs: go big or go home
opt.shiftwidth = 8
opt.softtabstop = 8
opt.tabstop = 8
opt.expandtab = false
-- case-insensitive search/replace
opt.ignorecase = true
-- unless uppercase in search term
opt.smartcase = true
-- never ever make my terminal beep
opt.vb = true
-- more useful diffs (nvim -d)
--- by ignoring whitespace
opt.diffopt:append("iwhite")
--- and using a smarter algorithm
--- https://vimways.org/2018/the-power-of-diff/
--- https://stackoverflow.com/questions/32365271/whats-the-difference-between-git-diff-patience-and-git-diff-histogram
--- https://luppeng.wordpress.com/2020/10/10/when-to-use-each-of-the-git-diff-algorithms/
opt.diffopt:append("algorithm:histogram")
opt.diffopt:append("indent-heuristic")
-- show a column at 80 characters as a guide for long lines
-- opt.colorcolumn = "80"
-- show more hidden characters
-- also, show tabs nicer
opt.listchars = "tab:^ ,nbsp:¬,extends:»,precedes:«,trail:•"

-------------------------------------------------------------------------------
--
-- hotkeys
--
-------------------------------------------------------------------------------
local keymap = vim.keymap

-- quick-save
keymap.set("n", "<leader>w", "<cmd>w<cr>")
-- make missing : less annoying
keymap.set("n", ";", ":")

keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })
-- Ctrl+h to stop searching
keymap.set("v", "<C-h>", "<cmd>nohlsearch<cr>")
keymap.set("n", "<C-h>", "<cmd>nohlsearch<cr>")
-- Jump to start and end of line using the home row keys
keymap.set("", "H", "^")
keymap.set("", "L", "$")
-- Neat X clipboard integration
-- <leader>p will paste clipboard into buffer
-- <leader>c will copy entire buffer into clipboard
keymap.set("n", "<leader>p", "<cmd>read !wl-paste<cr>")
keymap.set("n", "<leader>c", "<cmd>w !wl-copy<cr><cr>")
-- <leader><leader> toggles between buffers
keymap.set("n", "<leader><leader>", "<c-^>")
-- <leader>, shows/hides hidden characters
keymap.set("n", "<leader>,", ":set invlist<cr>")
-- always center search results
keymap.set("n", "n", "nzz", { silent = true })
keymap.set("n", "N", "Nzz", { silent = true })
keymap.set("n", "*", "*zz", { silent = true })
keymap.set("n", "#", "#zz", { silent = true })
keymap.set("n", "g*", "g*zz", { silent = true })
-- "very magic" (less escaping needed) regexes by default
keymap.set("n", "?", "?\\v")
keymap.set("n", "/", "/\\v")
keymap.set("c", "%s/", "%sm/")
-- open new file adjacent to current file
keymap.set("n", "<leader>o", ':e <C-R>=expand("%:p:h") . "/" <cr>')
-- no arrow keys --- force yourself to use the home row
keymap.set("n", "<up>", "<nop>")
keymap.set("n", "<down>", "<nop>")
keymap.set("i", "<up>", "<nop>")
keymap.set("i", "<down>", "<nop>")
keymap.set("i", "<left>", "<nop>")
keymap.set("i", "<right>", "<nop>")
-- let the left and right arrows be useful: they can switch buffers
keymap.set("n", "<left>", ":bp<cr>")
keymap.set("n", "<right>", ":bn<cr>")
-- make j and k move by visual line, not actual line, when text is soft-wrapped
keymap.set("n", "j", "gj")
keymap.set("n", "k", "gk")
-- handy keymap for replacing up to next _ (like in variable names)
keymap.set("n", "<leader>m", "ct_")

-------------------------------------------------------------------------------
--
-- configuring diagnostics
--
-------------------------------------------------------------------------------
-- Allow virtual text
vim.diagnostic.config({ virtual_text = true, virtual_lines = false })

-------------------------------------------------------------------------------
--
-- autocommands
--
-------------------------------------------------------------------------------
-- highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	pattern = "*",
	command = "silent! lua vim.highlight.on_yank({ timeout = 500 })",
})
-- jump to last edit position on opening file
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = "*",
	callback = function(ev)
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			-- except for in git commit messages
			-- https://stackoverflow.com/questions/31449496/vim-ignore-specifc-file-in-autocommand
			if not vim.fn.expand("%:p"):find(".git", 1, true) then
				vim.cmd('exe "normal! g\'\\""')
			end
		end
	end,
})
-- prevent accidental writes to buffers that shouldn't be edited
-- vim.api.nvim_create_autocmd("BufRead", { pattern = "*.orig", command = "set readonly" })
-- vim.api.nvim_create_autocmd("BufRead", { pattern = "*.pacnew", command = "set readonly" })
-- leave paste mode when leaving insert mode (if it was on)
-- vim.api.nvim_create_autocmd("InsertLeave", { pattern = "*", command = "set nopaste" })
-- help filetype detection (add as needed)
-- vim.api.nvim_create_autocmd('BufRead', { pattern = '*.ext', command = 'set filetype=someft' })
-- correctly classify mutt buffers
-- local email = vim.api.nvim_create_augroup("email", { clear = true })
-- vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
--	pattern = "/tmp/mutt*",
-- 	group = email,
-- 	command = "setfiletype mail",
-- })
-- also, produce "flowed text" wrapping
-- https://brianbuccola.com/line-breaks-in-mutt-and-vim/
-- vim.api.nvim_create_autocmd("Filetype", {
-- 	pattern = "mail",
-- 	group = email,
-- 	command = "setlocal formatoptions+=w",
-- })
-- shorter columns in text because it reads better that way
local text = vim.api.nvim_create_augroup("text", { clear = true })
for _, pat in ipairs({ "text", "markdown", "mail", "gitcommit" }) do
	vim.api.nvim_create_autocmd("Filetype", {
		pattern = pat,
		group = text,
		command = "setlocal spell tw=72 colorcolumn=73",
	})
end
--- tex has so much syntax that a little wider is ok
vim.api.nvim_create_autocmd("Filetype", {
	pattern = "tex",
	group = text,
	command = "setlocal spell tw=80 colorcolumn=81",
})
-- TODO: no autocomplete in text

-------------------------------------------------------------------------------
--
-- plugin configuration
--
-------------------------------------------------------------------------------
-- first, grab the manager
-- https://github.com/folke/lazy.nvim
--
local filetypes = { "dart", "go", "lua", "rust", "odin", "cpp" }

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)
-- then, setup!
require("lazy").setup({
	-- main color scheme
	{
		"sainnhe/gruvbox-material",
		priority = 1000,
		config = function()
			vim.cmd("let g:gruvbox_material_background = 'hard'")
			vim.cmd("colorscheme gruvbox-material")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local lualine = require("lualine")
			local lazy_status = require("lazy.status")

			lualine.setup({
				options = {
					theme = "gruvbox-material",
				},
				sections = {
					lualine_x = {
						{
							lazy_status.updates,
							cond = lazy_status.has_updates,
							-- color = { fg = "#ff9e64" },
						},
						{ "encoding" },
						{ "fileformat" },
						{ "filetype" },
					},
				},
			})
		end,
	},
	-- quick navigation
	{
		"https://codeberg.org/andyg/leap.nvim",
		config = function()
			vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
			vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
		end,
	},
	-- better %
	{
		"andymass/vim-matchup",
		config = function()
			vim.g.matchup_matchparen_offscreen = { method = "popup" }
		end,
	},
	-- option to center the editor
	{
		"shortcuts/no-neck-pain.nvim",
		version = "*",
		opts = {
			mappings = {
				enabled = true,
				toggle = false,
				toggleLeftSide = false,
				toggleRightSide = false,
				widthUp = false,
				widthDown = false,
				scratchPad = false,
			},
		},
		config = function()
			vim.keymap.set("", "<leader>t", function()
				vim.cmd([[
					:NoNeckPain
					:set formatoptions-=tc linebreak tw=0 cc=0 wrap wm=20 noautoindent nocindent nosmartindent indentkeys=
				]])
				-- make 0, ^ and $ behave better in wrapped text
				vim.keymap.set("n", "0", "g0")
				vim.keymap.set("n", "$", "g$")
				vim.keymap.set("n", "^", "g^")
			end)
		end,
	},
	-- auto-cd to root of git project
	-- 'airblade/vim-rooter'
	{
		"notjedi/nvim-rooter.lua",
		config = function()
			require("nvim-rooter").setup()
		end,
	},
	-- fzf support for ^p
	{
		"ibhagwan/fzf-lua",
		config = function()
			-- stop putting a giant window over my editor
			require("fzf-lua").setup({
				winopts = {
					split = "belowright 10new",
					preview = {
						hidden = true,
					},
				},
				files = {
					-- file icons are distracting
					file_icons = false,
					-- git icons are nice
					git_icons = true,
					-- but don't mess up my anchored search
					_fzf_nth_devicons = true,
				},
				buffers = {
					file_icons = false,
					git_icons = true,
					-- no nth_devicons as we'll do that
					-- manually since we also use
					-- with-nth
				},
				fzf_opts = {
					-- no reverse view
					["--layout"] = "default",
				},
			})
			-- when using C-p for quick file open, pass the file list through
			--
			--   https://github.com/jonhoo/proximity-sort
			--
			-- to prefer files closer to the current file.
			vim.keymap.set("", "<C-p>", function()
				opts = {}
				opts.cmd = "fd --color=never --hidden --type f --type l --exclude .git"
				local base = vim.fn.fnamemodify(vim.fn.expand("%"), ":h:.:S")
				if base ~= "." then
					-- if there is no current file,
					-- proximity-sort can't do its thing
					opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(vim.fn.expand("%")))
				end
				opts.fzf_opts = {
					["--scheme"] = "path",
					["--tiebreak"] = "index",
					["--layout"] = "default",
				}
				require("fzf-lua").files(opts)
			end)
			-- use fzf to search buffers as well
			vim.keymap.set("n", "<leader>;", function()
				require("fzf-lua").buffers({
					-- just include the paths in the fzf bits, and nothing else
					-- https://github.com/ibhagwan/fzf-lua/issues/2230#issuecomment-3164258823
					fzf_opts = {
						["--with-nth"] = "{-3..-2}",
						["--nth"] = "-1",
						["--delimiter"] = "[:\u{2002}]",
						["--header-lines"] = "false",
					},
					header = false,
				})
			end)
		end,
	},
	-- LSP
	{
		"neovim/nvim-lspconfig",
		config = function()
			-- Setup language servers.

			-- Bash LSP
			--if vim.fn.executable("bash-language-server") == 1 then
			--		vim.lsp.enable("bashls")
			--end

			-- texlab for LaTeX
			--if vim.fn.executable("texlab") == 1 then
			--		vim.lsp.enable("texlab")
			--end

			-- Global mappings.
			-- See `:help vim.diagnostic.*` for documentation on any of the below functions
			vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
			vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

					-- Buffer local mappings.
					-- See `:help vim.lsp.*` for documentation on any of the below functions
					local opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
					vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
					vim.keymap.set("n", "<leader>wl", function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end, opts)
					--vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
					vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts)
					vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
					vim.keymap.set("n", "<leader>f", function()
						vim.lsp.buf.format({ async = true })
					end, opts)

					local client = vim.lsp.get_client_by_id(ev.data.client_id)

					-- TODO: find some way to make this only apply to the current line.
					if client.server_capabilities.inlayHintProvider then
						vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
					end

					-- None of this semantics tokens business.
					-- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
					client.server_capabilities.semanticTokensProvider = nil
				end,
			})
		end,
	},
	-- LSP-based code-completion
	{
		"hrsh7th/nvim-cmp",
		-- load cmp on InsertEnter
		event = "InsertEnter",
		-- these dependencies will only be loaded when cmp loads
		-- dependencies are always lazy-loaded unless specified otherwise
		dependencies = {
			"neovim/nvim-lspconfig",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					-- REQUIRED by nvim-cmp. get rid of it once we can
					expand = function(args)
						vim.snippet.expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					-- Accept currently selected item.
					-- Set `select` to `false` to only confirm explicitly selected items.
					["<CR>"] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
				}, {
					{ name = "path" },
				}),
				experimental = {
					ghost_text = true,
				},
			})

			-- Enable completing paths in :
			cmp.setup.cmdline(":", {
				sources = cmp.config.sources({
					{ name = "path" },
				}),
			})
		end,
	},
	-- inline function signatures
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts)
			-- Get signatures (and _only_ signatures) when in argument lists.
			require("lsp_signature").setup({
				doc_lines = 0,
				handler_opts = {
					border = "none",
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			local treesitter = require("nvim-treesitter")

			treesitter.setup({
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
			})
			treesitter.install(filetypes)
		end,

		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				pattern = filetypes,
				callback = function()
					vim.treesitter.start()
				end,
			})
		end,
	},
})
