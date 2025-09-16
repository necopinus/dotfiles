-- Gruvbox Material color scheme
-- https://github.com/sainnhe/gruvbox-material

return {
	"sainnhe/gruvbox-material",

	-- Only load if Nerd Fonts are available (which indicates a fully themed terminal)
	cond = vim.g.have_nerd_font,

	-- Make sure that the colorscheme is loaded early
	lazy = false,
	priority = 1000,

	config = function()
		-- Optionally configure and load the colorscheme
		-- directly inside the plugin declaration.
		vim.g.gruvbox_material_background = "hard"
		-- vim.g.gruvbox_material_cursor = 'green'
		-- vim.g.gruvbox_material_ui_contrast = 'high'

		-- Load color scheme
		vim.cmd.colorscheme("gruvbox-material")
	end,
}
