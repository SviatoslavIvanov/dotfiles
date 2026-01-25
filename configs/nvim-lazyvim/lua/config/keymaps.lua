-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set
map("i", "jj", "<ESC>", { silent = true })

map("n", "<C-d>", "<C-d>zz", { desc = "Center cursor after moving down half-page", silent = true })
map("n", "<C-u>", "<C-u>zz", { desc = "Center cursor after moving up half-page", silent = true })

-- Save pasted word in register when replacing
map("x", "<leader>p", [["_dP]])

-- Yank into system clipboard
map({ "n", "v" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" }) -- yank motion
map({ "n", "v" }, "<leader>Y", '"+y$', { desc = "Yank to the end of line to system clipboard" }) -- yank line

-- Delete into system clipboard
map({ "v" }, "<leader>d", '"+d', { desc = "Delete to system clipboard" }) -- delete motion
map({ "v" }, "<leader>D", '"+D', { desc = "Delete to the end of line to system clipboard" }) -- delete line

-- Paste from system clipboard
map({ "n" }, "<leader>p", '"+p', { desc = "Paste after from system clipboard" }) -- paste after cursor
map({ "n", "v" }, "<leader>P", '"+P', { desc = "Paste before from system clipboard" }) -- paste before cursor
