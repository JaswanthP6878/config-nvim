vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

----
vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"

-- LSP
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)

vim.keymap.set("n", "gk", vim.lsp.buf.signature_help)
vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help)

vim.keymap.set("n", "gr", vim.lsp.buf.references)

vim.keymap.set("n", "<leader>tt", function()
  vim.cmd("vsplit | terminal")
end)

-- removing highlights for searched text since its annoying
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

vim.keymap.set("n", "<leader>tc", ":bd!<CR>")

-- to open diagnostics in the code
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

