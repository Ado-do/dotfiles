return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      component_separators = { left = "|", right = "|" },
      section_separators = {},
    },
    sections = {
      lualine_y = {
        { "lsp_status" },
        { "encoding", separator = "", padding = { left = 1 } },
        { "fileformat", padding = { left = 1, right = 1 } },
      },
      lualine_z = {
        { "progress", separator = " ", padding = { left = 1, right = 0 } },
        { "location", padding = { left = 0, right = 2 } },
      },
    },
  },
}
