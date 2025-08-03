-- Better buffer bar (though mini.tabline will work in a pinch)

return {
	"romgrk/barbar.nvim",

	dependencies = {
		"lewis6991/gitsigns.nvim", -- Git status
		"nvim-tree/nvim-web-devicons", -- File icons
	},

	opts = {
		-- FIXME: The below block of code makes for better-looking tabs,
		-- but causes a weird (and very annoying) delay in theme loading
		--
		--icons = {
		--	separator = { left = "", right = "▕" },
		--		separator_at_end = false,
		--		pinned = { separator = { left = "", right = "▕" } },
		--		inactive = { separator = { left = "", right = "▕" } },
		--},

		insert_at_end = true,

		-- Offset buffers when Neo-Tree is open
		sidebar_filetypes = {
			["neo-tree"] = { event = "BufWipeout" },
		},
	},
}
