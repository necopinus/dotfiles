-- Better buffer bar (though mini.tabline will work in a pinch)

return {
	"romgrk/barbar.nvim",

	-- FIXME: Rather than not loading at all if vim.g.have_nerd_font is false,
	--        we should instead fall back to using ASCII "icons". However,
	--        not loading nvim-web-devicons isn't enough on its own to do this,
	--        and setting icons.filetype.enabled = false does not appear to
	--        actually work.
	cond = vim.g.have_nerd_font,

	dependencies = {
		"lewis6991/gitsigns.nvim", -- Git status
		"nvim-tree/nvim-web-devicons", -- File icons, requires a Nerd Font
	},

	opts = {
		-- FIXME: The below block of code makes for better-looking tabs,
		--        but causes a weird (and very annoying) delay in theme
		--        loading
		--
		--icons = {
		--	separator = { left = "", right = "▕" },
		--	separator_at_end = false,
		--	pinned = { separator = { left = "", right = "▕" } },
		--	inactive = { separator = { left = "", right = "▕" } },
		--},

		insert_at_end = true,

		-- Offset buffers when Neo-Tree is open
		sidebar_filetypes = {
			["neo-tree"] = { event = "BufWipeout" },
		},
	},
}
