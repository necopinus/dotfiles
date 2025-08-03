-- Obsidian 🤝 Neovim
-- https://github.com/obsidian-nvim/obsidian.nvim

return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",

	dependencies = {
		"nvim-lua/plenary.nvim", -- Required

		-- The following are loaded
		-- as part of init.lua
		-- "Saghen/blink.cmp",
		-- "nvim-telescope/telescope.nvim",

		{
			"folke/snacks.nvim", -- Image support

			---@type snacks.Config
			opts = {
				image = {
					resolve = function(path, src)
						if require("obsidian.api").path_is_note(path) then
							return require("obsidian.api").resolve_image_path(src)
						end
					end,
				},
			},
		},

		-- The following is loaded as
		-- part of nvim-treesitter.lua
		-- "OXY2DEV/markview.nvim",
	},

	---@module 'obsidian'
	---@type obsidian.config
	opts = {
		-- A list of workspace names, paths, and configuration overrides.
		-- If you use the Obsidian app, the 'path' of a workspace should generally be
		-- your vault root (where the `.obsidian` folder is located).
		-- When obsidian.nvim is loaded by your plugin manager, it will automatically set
		-- the workspace to the first workspace in the list whose `path` is a parent of the
		-- current markdown file being edited.
		workspaces = {
			{
				name = "zibaldone",
				path = "~/notes/zibaldone",
			},
			{
				name = "grimoire",
				path = "~/notes/grimoire",
			},
			{
				name = "some-remarks",
				path = "~/notes/some-remarks",
			},
			{
				name = "yak-collective",
				path = "~/src/yakcollective",
			},
		},

		-- Optional, if you keep notes in a specific subdirectory of your vault.
		notes_subdir = "notes",

		daily_notes = {
			-- Optional, if you keep daily notes in a separate directory.
			folder = "journals",
			-- Optional, if you want to change the date format for the ID of daily notes.
			date_format = "%Y-%m-%d",
			-- Optional, if you want to change the date format of the default alias of daily notes.
			alias_format = "%B %-d, %Y",
			-- Optional, default tags to add to each new daily note created.
			default_tags = { "Journal" },
			-- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
			template = "Journal initialization.md",
			-- Optional, if you want `Obsidian yesterday` to return the last work day or `Obsidian tomorrow` to return the next work day.
			workdays_only = false,
		},

		-- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
		completion = {
			-- Enables completion using nvim_cmp
			nvim_cmp = false,
			-- Enables completion using blink.cmp
			blink = true,
		},

		-- Where to put new notes. Valid options are
		-- _ "current_dir" - put new notes in same directory as the current buffer.
		-- _ "notes_subdir" - put new notes in the default notes subdirectory.
		new_notes_location = "current_dir",

		-- Optional, customize how note IDs are generated given an optional title.
		---@param title string|?
		---@return string
		note_id_func = function(title)
			return title
		end,

		-- Optional, customize how note file names are generated given the ID, target directory, and title.
		---@param spec { id: string, dir: obsidian.Path, title: string|? }
		---@return string|obsidian.Path The full path to the new note.
		note_path_func = function(spec)
			-- This is equivalent to the default behavior.
			local path = spec.dir / tostring(spec.id)
			return path:with_suffix(".md")
		end,

		-- Optional, boolean or a function that takes a filename and returns a boolean.
		-- `true` indicates that you don't want obsidian.nvim to manage frontmatter.
		disable_frontmatter = false,

		-- Optional, alternatively you can customize the frontmatter data.
		---@return table
		note_frontmatter_func = function(note)
			-- Add the title of the note as an alias.
			if note.title then
				note:add_alias(note.title)
			end

			local out = {
				id = note.id,
				title = note.title,
				aliases = note.aliases,
				tags = note.tags,
			}

			-- `note.metadata` contains any manually added fields in the frontmatter.
			-- So here we just make sure those fields are kept in the frontmatter.
			if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
				for k, v in pairs(note.metadata) do
					out[k] = v
				end
			end

			return out
		end,

		-- Optional, for templates (see https://github.com/obsidian-nvim/obsidian.nvim/wiki/Using-templates)
		templates = {
			folder = "templates",
			date_format = "%Y-%m-%d",
			time_format = "%H:%M",

			-- A map for custom variables, the key should be the variable and the value a function.
			-- Functions are called with obsidian.TemplateContext objects as their sole parameter.
			-- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#substitutions
			substitutions = {},
		},

		picker = {
			-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', 'mini.pick' or 'snacks.pick'.
			name = "telescope.nvim",
		},

		-- Optional, by default, `:ObsidianBacklinks` parses the header under
		-- the cursor. Setting to `false` will get the backlinks for the current
		-- note instead. Doesn't affect other link behaviour.
		backlinks = {
			parse_headers = false,
		},

		-- Enable Obsidian comments
		comment = {
			enabled = true,
		},

		-- Optional, configure additional syntax highlighting / extmarks.
		-- Character substitution requires you have `conceallevel` set
		-- to 1 or 2. See `:help conceallevel` for more details.
		ui = {
			hl_groups = {
				-- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
				ObsidianTodo = { bold = true, fg = "Yellow" },
				ObsidianDone = { bold = true, fg = "Green" },
				ObsidianRightArrow = { bold = true, fg = "Yellow" },
				ObsidianTilde = { bold = true, fg = "Red" },
				ObsidianImportant = { bold = true, fg = "Red" },
				ObsidianBullet = { bold = true, fg = "Blue" },
				ObsidianRefText = { underline = true, fg = "Magenta" },
				ObsidianExtLinkIcon = { fg = "Blue" },
				ObsidianTag = { italic = true, fg = "Cyan" },
				ObsidianBlockID = { italic = true, fg = "Blue" },
				ObsidianHighlightText = { bg = "Yellow" },
			},
		},

		---@class obsidian.config.AttachmentsOpts
		---
		---Default folder to save images to, relative to the vault root.
		---@field img_folder? string
		---
		---Default name for pasted images
		---@field img_name_func? fun(): string
		---
		---Default text to insert for pasted images, for customizing, see: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Images
		---@field img_text_func? fun(path: obsidian.Path): string
		---
		---Whether to confirm the paste or not. Defaults to true.
		---@field confirm_img_paste? boolean
		attachments = {
			img_folder = "assets",
		},

		---@class obsidian.config.FooterOpts
		---
		---@field enabled? boolean
		---@field format? string
		---@field hl_group? string
		---@field separator? string|false Set false to disable separator; set an empty string to insert a blank line separator.
		footer = {
			separator = string.rep("─", 80),
		},

		-- Disable legacy commands (and warning message)
		legacy_commands = false,
	},
}
