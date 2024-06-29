local conform = require("conform")
local util = require("conform.util")

conform.setup({
  formatters = {
    biome = {
      command = "biome",
      stdin = true,
      args = { "format", "--stdin-file-path", "$FILENAME" },
      cwd = util.root_file({
        "biome.json",
        "biome.jsonc",
      }),
    },
  },

  formatters_by_ft = {
    css             = { "prettier" },
    graphql         = { "prettier" },
    javascript      = {{ "biome", "prettier" }},
    javascriptreact = {{ "biome", "prettier" }},
    json            = {{ "biome", "prettier" }},
    lua             = { "stylua" },
    markdown        = { "prettier" },
    rust            = { "rustfmt" },
    typescript      = {{ "biome", "prettier" }},
    typescriptreact = {{ "biome", "prettier" }},
    yaml            = { "prettier" },
  },

  format_on_save = {
    lsp_fallback = true,
    async = false,
    timeout_ms = 1000,
  },
})

vim.keymap.set({ "n", "v" }, "<leader>mf", conform.format, { desc = "Format file / range" })
