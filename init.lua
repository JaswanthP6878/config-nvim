vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

----
vim.g.mapleader = " "

vim.opt.clipboard = "unnamedplus"

vim.opt.wrap= false

local function apply_ghostty_harmonized_highlights()
  local set = vim.api.nvim_set_hl

  -- Keep editor/neo-tree surfaces transparent so Ghostty opacity is consistent.
  local transparent_groups = {
    "Normal",
    "NormalNC",
    "SignColumn",
    "EndOfBuffer",
    "NormalFloat",
    "FloatBorder",
    "Pmenu",
    "NeoTreeNormal",
    "NeoTreeNormalNC",
    "NeoTreeEndOfBuffer",
    "NeoTreeFloatBorder",
    "NeoTreeWinSeparator",
  }

  for _, group in ipairs(transparent_groups) do
    set(0, group, { bg = "none" })
  end

  set(0, "NeoTreeNormal", { link = "Normal" })
  set(0, "NeoTreeNormalNC", { link = "NormalNC" })
end

_G.apply_ghostty_harmonized_highlights = apply_ghostty_harmonized_highlights
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    apply_ghostty_harmonized_highlights()
  end,
})

-- LSP
vim.keymap.set("n", "<leader>tt", function()
  vim.cmd("vsplit | terminal")
end)

-- removing highlights for searched text since its annoying
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]])

vim.keymap.set("n", "<leader>tc", ":bd!<CR>")

vim.keymap.set("n", "<leader>nf", function()
  require("config.new_file").create_from_prompt()
end, { desc = "Create file by path" })

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
require("config.java_templates").setup()
