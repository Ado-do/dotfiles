-- Configuration for mini.nvim modules

-- UI modules load immediately so the first frame is styled.
require("mini.notify").setup() -- Routes vim.notify
require("mini.icons").setup()
require("mini.pairs").setup()

local mini_diff = require("mini.diff")
mini_diff.setup({
  view = {
    style = "sign",
    signs = { add = "┃", change = "┃", delete = "_" },
  },
})
vim.keymap.set("n", "]h", function() mini_diff.goto_hunk("next") end, { desc = "Next Git Hunk" })
vim.keymap.set("n", "[h", function() mini_diff.goto_hunk("prev") end, { desc = "Previous Git Hunk" })
vim.keymap.set("n", "<leader>hP", function() mini_diff.toggle_overlay(0) end, { desc = "Toggle Diff Overlay" })

-- File explorer: set up eagerly so `nvim <dir>` opens it instead of netrw
local mini_files = require("mini.files")
mini_files.setup()
vim.keymap.set("n", "<leader>e", function()
  if not mini_files.close() then
    local buf_name = vim.api.nvim_buf_get_name(0)
    if buf_name ~= "" and vim.fn.filereadable(buf_name) == 1 then
      mini_files.open(buf_name, true)
    else
      mini_files.open(nil, true)
    end
  end
end, { desc = "Toggle File Explorer" })

-- Everything else is deferred until after startup.
vim.schedule(function()
  -- Fuzzy finder
  local mini_pick = require("mini.pick")
  mini_pick.setup()
  vim.keymap.set("n", "<leader><leader>", function() mini_pick.builtin.files() end, { desc = "Find Files" })
  vim.keymap.set("n", "<leader>/", function() mini_pick.builtin.grep_live() end, { desc = "Live Grep" })
  vim.keymap.set("n", "<leader>,", function() mini_pick.builtin.buffers() end, { desc = "Find Buffers" })
  vim.keymap.set("n", "<leader>?", function() mini_pick.builtin.help() end, { desc = "Search Help" })

  -- Safe buffer removal
  local mini_bufremove = require("mini.bufremove")
  mini_bufremove.setup()
  vim.keymap.set("n", "<leader>bd", function() mini_bufremove.delete(0, false) end, { desc = "Delete Buffer" })

  -- Surround (sa / sd / sr)
  require("mini.surround").setup()

  -- On-screen keybinding hints
  local mini_clue = require("mini.clue")
  mini_clue.setup({
    triggers = {
      { mode = "n", keys = "<Leader>" },
      { mode = "x", keys = "<Leader>" },
      { mode = "n", keys = "g" },
      { mode = "n", keys = "z" },
      { mode = "n", keys = "[" },
      { mode = "n", keys = "]" },
      { mode = "n", keys = "<C-w>" },
      { mode = "n", keys = "'" },
      { mode = "n", keys = "`" },
      { mode = "x", keys = "'" },
      { mode = "x", keys = "`" },
      { mode = "n", keys = '"' },
      { mode = "x", keys = '"' },
      { mode = "i", keys = "<C-r>" },
      { mode = "c", keys = "<C-r>" },
      { mode = "i", keys = "<C-x>" },
    },
    clues = {
      mini_clue.gen_clues.builtin_completion(),
      mini_clue.gen_clues.g(),
      mini_clue.gen_clues.marks(),
      mini_clue.gen_clues.registers(),
      mini_clue.gen_clues.windows(),
      mini_clue.gen_clues.square_brackets(),
      mini_clue.gen_clues.z(),
    },
  })
end)

-- Commenting (gc / gcc) and completion are handled natively.
