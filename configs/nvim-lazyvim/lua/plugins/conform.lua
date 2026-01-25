return {
  "stevearc/conform.nvim",
  optional = true,
  opts = {
    formatters_by_ft = {
      ["java"] = { "google-java-format" },
      ["xml"] = { "xmlformatter" },
      -- ["sql"] = { "sleek" },
      ["python"] = { "ruff" },
      ["kotlin"] = { "ktlint" },
      ["sql"] = { "pgformatter" },
    },
  },
}
