return {
  "akinsho/bufferline.nvim",
  enabled = true,
  -- function so `require("bufferline")` runs when the plugin loads, not during spec parsing
  opts = function(_, opts)
    local o = opts.options
    o.mode = "tabs"
    o.auto_toggle_bufferline = true
    o.style_preset = require("bufferline").style_preset.no_italic
    o.show_buffer_close_icons = false
    o.offsets = {
      {
        filetype = "snacks_layout_box",
        text = "󰙅  File Explorer",
        separator = true,
      },
    }
  end,
}
