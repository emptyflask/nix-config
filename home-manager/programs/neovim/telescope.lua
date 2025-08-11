local actions = require('telescope.actions')
local telescope = require('telescope')

telescope.setup {
  extensions = {
    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
      -- the default case_mode is "smart_case"
    },
    fzy_native = {
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
    }
  },
  pickers = {
    live_grep = {
      mappings = {
        i = { ["<c-f>"] = actions.to_fuzzy_refine },
      },
    },
  },
}

telescope.load_extension('fzy_native')
