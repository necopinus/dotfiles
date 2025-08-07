-- CodeCompanion
-- https://github.com/olimorris/codecompanion.nvim

return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"ravitemer/mcphub.nvim", -- MCP server integration
		"ravitemer/codecompanion-history.nvim", -- Chat history support
		"OXY2DEV/markview.nvim", -- Better chat buffer formatting
		{
			"echasnovski/mini.diff",
			config = function()
				local diff = require("mini.diff")
				diff.setup({
					source = diff.gen_source.none(), -- Disabled by default
				})
			end,
		},
		{
			"HakonHarnes/img-clip.nvim",
			opts = {
				filetypes = {
					codecompanion = {
						prompt_for_file_name = false,
						template = "[Image]($FILE_PATH)",
						use_absolute_path = true,
					},
				},
			},
		},
	},
	config = function()
		require("codecompanion").setup({
			strategies = {
				chat = {
					adapter = "anthropic",
				},
				inline = {
					adapter = "anthropic",
				},
				cmd = {
					adapter = "anthropic",
				},
			},
			extensions = {
				mcphub = {
					callback = "mcphub.extensions.codecompanion",
				},
			},
		})

		-- Recommended keymaps
		-- https://codecompanion.olimorris.dev/getting-started.html#suggested-plugin-workflow
		vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
		vim.keymap.set(
			{ "n", "v" },
			"<LocalLeader>a",
			"<cmd>CodeCompanionChat Toggle<cr>",
			{ noremap = true, silent = true }
		)
		vim.keymap.set({ "v" }, "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

		-- Expand 'cc' into 'CodeCompanion' in the command line
		vim.cmd([[cab cc CodeCompanion]])
	end,
}
