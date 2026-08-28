return {
  "folke/zen-mode.nvim",
  opts = {
    window = {
      options = {
        number = true,
      },
    },
    plugins = {
      gitsigns = {
        enabled = true,
      },
      tmux = {
        enabled = true,
      },
    },
  },
  keys = { {
    "<leader>z",
    "<cmd>ZenMode<CR>",
    desc = "Toggle ZenMode",
  } },
}
