-- Configure Tokyo Night (load failures are reported by init.lua)
require("tokyonight").setup({
  transparent = true,
  styles = {
    sidebars = "transparent",
    floats = "transparent",
  },
  on_colors = function(c)
    c.comment = "#7e86ae"
    c.border = c.blue7
  end,
  on_highlights = function(hl, c)
    hl.TabLine = { bg = "none", fg = c.comment }
    hl.TabLineSel = { bg = "none", fg = c.fg }
    hl.TabLineFill = { bg = "none" }
    hl.LineNr = { bg = "none", fg = c.comment }
    hl.CursorLineNr = { bg = "none", fg = c.warning }
    hl.SignColumn = { bg = "none" }
    hl.StatusLine = { bg = "none" }
    hl.StatusLineNC = { bg = "none" }
  end,
})

vim.cmd.colorscheme("tokyonight-night")
