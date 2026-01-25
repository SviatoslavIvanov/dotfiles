return {
  "folke/zen-mode.nvim",
  opts = {
    options = {
      number = true,
    },
    plugins = {
      gitsigns = {
        enabled = true,
      },
      kitty = {
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
