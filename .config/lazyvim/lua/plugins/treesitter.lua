return {
  "nvim-treesitter/nvim-treesitter",
  -- parsers no language extra installs: Tailwind/CSS stylesheets and plain SQL migrations
  opts = { ensure_installed = { "css", "sql" } },
}
