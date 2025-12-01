require("obsidian").setup({
  legacy_commands = false,
  workspaces = {
    {
      name = "cookbook",
      path = "~/notes/Cookbook",
    },
    {
      name = "notes",
      path = "~/notes/Obsidian",
    },
  },
})
