return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  init = function()
    vim.o.foldcolumn = "1" -- '0' is not bad
    vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
    vim.o.foldlevelstart = 99
    vim.o.foldenable = true
  end,
  opts = {
    provider_selector = function(bufnr, filetype, buftype)
      return { "lsp" }
    end,
    close_fold_kinds_for_ft = {
      default = { "imports", "comment" },
    },
  },
  config = function(_, opts)
    require("ufo").setup(opts)
  end,
  keys = {
    {
      "zR",
      function()
        require("ufo").openAllFolds()
      end,
      mode = "n",
      desc = "UFO: Open All Folds",
    },
    {
      "zM",
      function()
        require("ufo").closeAllFolds()
      end,
      mode = "n",
      desc = "UFO: Close All Folds",
    },
    {
      "zK",
      function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hower()
        end
      end,
      mode = "n",
      desc = "UFO: Peek Folded Lines Under Cursor",
    },
    -- Optional: some people like to map zr and zm for consistency with za
    -- {
    --   "zr",
    --   function()
    --     require("ufo").openFoldsExceptKinds()
    --   end,
    --   mode = "n",
    --   desc = "UFO: Open Folds (selective)",
    -- }, -- Example, see UFO docs for more
    -- {
    --   "zm",
    --   function()
    --     require("ufo").closeFoldsWith()
    --   end,
    --   mode = "n",
    --   desc = "UFO: Close Folds (selective)",
    -- }, -- Example
  },
  event = "VeryLazy",
}
