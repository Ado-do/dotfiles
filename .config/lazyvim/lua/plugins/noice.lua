return {
  "folke/noice.nvim",
  opts = {
    lsp = {
      signature = {
        enabled = true,
        auto_open = { trigger = false },
      },
    },
    presets = {
      -- Adds a border to hover docs and signature help
      lsp_doc_border = true,
    },
  },
}
