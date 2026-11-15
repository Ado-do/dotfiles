if not vim.g.neovide then return end

-- Default GUI font
vim.o.guifont = "IosevkaTerm NF Medium:h18"

-- Background transparency
vim.g.neovide_opacity = 0.9

-- Smooth cursor animations
vim.g.neovide_cursor_animation_length = 0.1

-- Smooth scrolling animation
vim.g.neovide_scroll_animation_length = 0.25

-- Render quality tweaks
vim.g.neovide_text_gamma = 0.8
vim.g.neovide_text_contrast = 0.15

-- Font size (scale factor) keymaps
local function scale(delta)
  local current = vim.g.neovide_scale_factor or 1.0
  vim.g.neovide_scale_factor = math.max(0.5, math.min(3.0, current + delta))
end

local maps = {
  ["<C-=>"] = { 0.1, "Increase font size" },
  ["<C-+>"] = { 0.1, "Increase font size" },
  ["<C-ScrollWheelUp>"] = { 0.1, "Increase font size" },
  ["<C-->"] = { -0.1, "Decrease font size" },
  ["<C-_>"] = { -0.1, "Decrease font size" },
  ["<C-ScrollWheelDown>"] = { -0.1, "Decrease font size" },
}

for lhs, m in pairs(maps) do
  vim.keymap.set({ "n", "v", "i" }, lhs, function() scale(m[1]) end, { silent = true, desc = m[2] })
end

vim.keymap.set({ "n", "v", "i" }, "<C-0>", function() vim.g.neovide_scale_factor = 1.0 end,
  { silent = true, desc = "Reset font size" })
