return {
  "saghen/blink.cmp",
  -- plain table so it deep-merges with LazyVim's defaults instead of replacing them
  opts = {
    completion = {
      menu = { auto_show = true },
      -- menu = { border = "rounded" },
      -- documentation = { window = { border = "rounded" } },
      ghost_text = { enabled = false },
    },
    keymap = { preset = "default" },
  },
}
