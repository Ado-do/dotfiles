return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    -- markdown is linted by the rumdl LSP server instead of markdownlint-cli2
    opts.linters_by_ft.markdown = {}
  end,
}
