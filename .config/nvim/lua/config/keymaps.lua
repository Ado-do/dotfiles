vim.g.mapleader = " "
local keymap = vim.keymap.set

-- File saving
keymap("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })

-- Clear search highlighting
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear Search Highlights" })

-- System Clipboard Integration & Register Mappings
-- Visual P already pastes without replacing the register (:h v_P).
keymap({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to System Clipboard" })
keymap("n", "<leader>Y", [["+Y]], { desc = "Yank Line to System Clipboard" })
keymap("n", "<leader>by", "<cmd>%y +<cr>", { desc = "Yank whole buffer to system clipboard" })
keymap("n", "<leader>p", '"+p', { desc = "Paste after from system clipboard" })
keymap("n", "<leader>P", '"+P', { desc = "Paste before from system clipboard" })
keymap("n", "x", '"_x', { desc = "Delete character without overwriting register" })

-- Visual Indentation
keymap("x", "<", "<gv", { desc = "Indent left and reselect" })
keymap("x", ">", ">gv", { desc = "Indent right and reselect" })

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
keymap("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
keymap("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
keymap("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Window resizing
local resize_step = 2
keymap("n", "<C-Up>", "<cmd>resize +" .. resize_step .. "<cr>", { desc = "Increase window height" })
keymap("n", "<C-Down>", "<cmd>resize -" .. resize_step .. "<cr>", { desc = "Decrease window height" })
keymap("n", "<C-Left>", "<cmd>vertical resize -" .. resize_step .. "<cr>", { desc = "Decrease window width" })
keymap("n", "<C-Right>", "<cmd>vertical resize +" .. resize_step .. "<cr>", { desc = "Increase window width" })

-- Terminal
keymap("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode", silent = true })

-- Buffer / quickfix / diagnostic navigation ([b ]b, [q ]q, [d ]d, ...) are Neovim defaults.

-- Quickfix List compilation bindings
keymap("n", "<leader>m", "<cmd>make<cr>", { desc = "Run Make (Background Build)" })
keymap("n", "<leader>co", "<cmd>copen<cr>", { desc = "Open Quickfix List" })
keymap("n", "<leader>cc", "<cmd>cclose<cr>", { desc = "Close Quickfix List" })

-- Daily note
local function open_daily_note()
  local home = vim.fn.expand("~")
  local filename = os.date("%Y-%m-%d") .. ".md"
  local filepath = home .. "/" .. filename
  vim.cmd.edit(vim.fn.fnameescape(filepath))
end

vim.api.nvim_create_user_command("Daily", open_daily_note, {
  desc = "Open daily markdown file in home directory",
})

keymap("n", "<leader>.", "<cmd>Daily<cr>", { desc = "Open daily note" })
