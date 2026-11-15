-- Neovide config

if not vim.g.neovide then
  return
end

vim.o.guifont = "IosevkaTerm NF:h16"
vim.g.neovide_padding_top = 10
vim.g.neovide_opacity = 0.85
vim.g.neovide_cursor_animation_length = 0.1

vim.g.neovide_scale_factor = 1.0
local font_adjustment = 1.05

-- Zoom In: Ctrl + =
vim.keymap.set("n", "<C-=>", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * font_adjustment
end, { desc = "Zoom In" })

-- Zoom Out: Ctrl + -
vim.keymap.set("n", "<C-->", function()
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor / font_adjustment
end, { desc = "Zoom Out" })

-- Reset Zoom: Ctrl + 0
vim.keymap.set("n", "<C-0>", function()
  vim.g.neovide_scale_factor = 1.0
end, { desc = "Reset Zoom" })
