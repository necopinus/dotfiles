-- Gruvbox Material color scheme
-- https://github.com/sainnhe/gruvbox-material

return {
  'sainnhe/gruvbox-material',

  -- Make sure that the colorscheme is loaded early
  lazy = false,
  priority = 1000,

  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.gruvbox_material_background = 'hard'
    -- vim.g.gruvbox_material_cursor = 'green'
    -- vim.g.gruvbox_material_ui_contrast = 'high'

    -- Load color scheme
    vim.o.background = 'light'
    vim.cmd.colorscheme('gruvbox-material')
  end
}
