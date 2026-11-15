return {
  "folke/tokyonight.nvim",
  opts = {
    -- style = "day",
    style = "night",

    transparent = true,
    styles = {
      sidebars = "transparent",
      floats = "transparent",
    },
    on_colors = function(c)
      c.comment = "#7e86ae"
      c.border = c.blue7
      c.bg_statusline = c.none
    end,
    -- on_highlights = function(hl, c)
    -- hl.TabLineFill = {
    --   bg = c.none,
    -- }
    -- end,
  },
}
