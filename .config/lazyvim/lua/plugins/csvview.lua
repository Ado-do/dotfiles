return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle", "CsvViewInfo" },
  opts = {
    parser = { comments = { "#", "//" } },
    keymaps = {
      -- Text objects for selecting fields
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "]f", mode = { "n", "v" } },
      jump_prev_field_end = { "[f", mode = { "n", "v" } },
      jump_next_field_start = { "]F", mode = { "n", "v" } },
      jump_prev_field_start = { "[F", mode = { "n", "v" } },
      jump_next_row = { "]r", mode = { "n", "v" } },
      jump_prev_row = { "[r", mode = { "n", "v" } },
    },
  },
  keys = {
    { "<leader>cv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CsvView", ft = { "csv", "tsv" } },
    { "<leader>cV", "<cmd>CsvViewInfo<cr>", desc = "CsvView Info", ft = { "csv", "tsv" } },
    {
      "<leader>cb",
      function()
        vim.b.csvview_border = not vim.b.csvview_border
        vim.cmd.CsvViewEnable("display_mode=" .. (vim.b.csvview_border and "border" or "highlight"))
      end,
      desc = "Toggle CsvView border",
      ft = { "csv", "tsv" },
    },
    {
      "<leader>cp",
      function()
        vim.b.csvview_pin = not vim.b.csvview_pin
        vim.cmd.CsvViewEnable("sticky_columns=" .. (vim.b.csvview_pin and 1 or 0))
      end,
      desc = "Toggle CsvView pinned column",
      ft = { "csv", "tsv" },
    },
  },
}
