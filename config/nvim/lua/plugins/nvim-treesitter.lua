-- Highlight, edit, and navigate code

return {
	"nvim-treesitter/nvim-treesitter",

	branch = "master", -- This will need to be changed to 'main' at some point, not sure when
	dependencies = {
		{
			"OXY2DEV/markview.nvim", -- Obsidian-like Markdown rendering
			lazy = false,

			-- Try to force markview to load before nvim-treesitter
			priority = 49,

			-- Loaded as part of init.lua
			-- dependencies = {
			-- 	require("plugins.blink"),
			-- },

			config = function()
				-- Enable presets
				local presets = require("markview.presets")

				-- Basic configuration
				require("markview").setup({
					preview = {
						filetypes = { "md", "markdown", "rmd", "quarto" },
						icon_provider = "mini", -- Loaded/Enabled in mini.lua
					},
					markdown = {
						headings = presets.headings.arrowed,
						horizontal_rules = presets.horizontal_rules.thin,
						tables = presets.tables.rounded,
					},
				})

				-- Code block editor
				require("markview.extras.editor").setup()

				-- Override some highlight group backgrounds
				-- modify_hl(): https://github.com/neovim/neovim/discussions/24405#discussioncomment-6502496
				function modify_hl(ns, name, changes)
					local def = vim.api.nvim_get_hl(ns, { name = name, link = false })
					vim.api.nvim_set_hl(ns, name, vim.tbl_deep_extend("force", def, changes))
				end
				local cursor_line_hl = vim.api.nvim_get_hl_by_name("CursorLine", true)
				modify_hl(0, "MarkviewCode", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewCodeFg", { fg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon0", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon1", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon2", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon3", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon4", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon5", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewIcon6", { bg = cursor_line_hl.background })
				modify_hl(0, "MarkviewInlineCode", { bg = cursor_line_hl.background })
			end,
		},
	},
	build = ":TSUpdate",
	lazy = false,
	main = "nvim-treesitter.configs", -- Sets main module to use for opts

	-- [[ Configure Treesitter ]] See `:help nvim-treesitter`
	opts = {
		-- Kickstart.nvim defaults + languages from nvim-lspconfig.lua + a few more
		ensure_installed = {
			"bash",
			"bibtex",
			"c",
			"c_sharp",
			"cmake",
			"comment",
			"cpp",
			"css",
			"csv",
			"desktop", -- Systemd, et al.
			"diff",
			"dockerfile",
			"git_config",
			"git_rebase",
			"gitattributes",
			"gitcommit",
			"gitignore",
			"gnuplot",
			"go",
			"gomod",
			"gosum",
			"gotmpl",
			"gowork",
			"gpg",
			"graphql",
			"haskell",
			"html",
			"http",
			"ini", -- Experimental
			"java",
			"javadoc",
			"javascript",
			"jq",
			"json",
			"jsonc",
			"kotlin",
			"latex",
			"ledger",
			"lua",
			"luadoc",
			"make",
			"markdown",
			"markdown_inline",
			"matlab",
			-- 'mermaid', -- No syntax highlighting
			"nix",
			"objc",
			"passwd",
			"perl",
			"php",
			"phpdoc", -- Experimental
			"pod",
			"powershell",
			"printf",
			"proto",
			"python",
			"query",
			"readline",
			"regex",
			"requirements",
			"robots",
			"rst",
			-- 'ruby', -- Needs regex-based highlighting; see below
			"rust",
			"scala",
			"scss",
			"smithy",
			"solidity",
			"soql",
			"sql",
			"ssh_config",
			"swift",
			"tcl",
			"tmux",
			"todotxt", -- Experimental
			"toml",
			"tsv",
			"typescript",
			"typst",
			"udev",
			"vim",
			"vimdoc",
			"xml",
			"xresources",
			"yaml",
			"zathurarc",
		},

		-- Autoinstall languages that are not installed
		auto_install = true,

		highlight = {
			enable = true,

			-- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
			--  If you are experiencing weird indenting issues, add the language to
			--  the list of additional_vim_regex_highlighting and disabled languages for indent.
			additional_vim_regex_highlighting = {
				"ruby",
			},
		},
		incremental_selection = {
			enable = true,
			-- These are just the default keybindings, for reference
			keymaps = {
				init_selection = "gnn",
				node_incremental = false, -- Default 'grn' conflicts with nvim-lspconfig [R]e[n]ame keybinding
				scope_incremental = "grc",
				node_decremental = "grm",
			},
		},
		indent = {
			enable = true,
			disable = {
				"ruby",
			},
		},
	},
}

--[[

MIT License
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

--]]
