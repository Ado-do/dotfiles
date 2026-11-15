-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Add neovide config
require("config.neovide")

vim.g.autoformat = false
vim.g.root_spec = { "cwd" }

local opt = vim.opt

opt.mouse = "nvi"
opt.clipboard = ""
opt.cursorline = true
opt.cursorlineopt = "number"

opt.tabstop = 4
opt.shiftwidth = 4
opt.wrap = false
opt.scrolloff = 10
opt.breakindent = true

opt.title = true
opt.titlestring = "lazyvim | %{fnamemodify(getcwd(), ':t')}"

opt.spell = false
opt.spelllang = { "es", "en" }

vim.filetype.add({
  extension = {
    gp = "gnuplot",
  },
})
