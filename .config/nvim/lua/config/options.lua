-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Gutter & cursor
vim.opt.signcolumn = "yes"       -- Stable gutter so mini.diff signs don't shift text
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.showmode = false        -- Mode is not shown anywhere (cursor shape is enough)

-- Indentation & Tabs (Standard defaults: 4 spaces)
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4

-- Search behavior
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- System Integration & Visuals
vim.opt.mouse = "a"
vim.opt.updatetime = 250        -- Faster diagnostics/git gutter refresh
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Splits layout
vim.opt.laststatus = 3
vim.opt.statusline = "%<%f %m%r%=%l:%c " -- Minimal: path, flags, line:col
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Neovim 0.12+ Native Features
vim.opt.autocomplete = true     -- Native completion popup
vim.opt.complete = { "o", ".", "w", "b" } -- "o": LSP items via omnifunc
vim.opt.completeopt = { "menuone", "noselect", "fuzzy", "popup" }
vim.opt.smoothscroll = true     -- Smooth scrolling on wrapped lines

vim.opt.undofile = true

-- Spell checking languages (enabled in after/ftplugin)
vim.opt.spelllang = { "en", "es" }

-- Wildmode & scrolloff
vim.opt.wildmode = { "longest", "list", "full" }
vim.opt.scrolloff = 10

-- Quality of life
vim.opt.confirm = true       -- Prompt to save instead of failing on quit
vim.opt.splitkeep = "screen" -- Keep view stable when opening splits
