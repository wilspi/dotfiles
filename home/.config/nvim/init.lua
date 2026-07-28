-- Deliberately small: nvim here is for quick edits over ssh, not an IDE.
-- Real editing happens in Zed.

vim.g.mapleader = " "

local o = vim.opt
o.number = true
o.relativenumber = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.incsearch = true
o.hlsearch = true
o.termguicolors = true
o.signcolumn = "yes"
o.scrolloff = 5
o.clipboard = "unnamedplus"
o.undofile = true
o.swapfile = false
o.updatetime = 250
o.mouse = "a"

vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "write" })
vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "quit" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>")

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.highlight.on_yank() end,
})
