return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      enabled = false,
    },
    picker = {
      sources = {
        explorer = {
          layout = {
            layout = {
              min_width = 20,
              width = 27,
            },
          },
        },
      },
    },
    -- image = { enabled = vim.env.TERM == "xterm-kitty" and true or false },
    -- image = { enabled = true },
  },
}
