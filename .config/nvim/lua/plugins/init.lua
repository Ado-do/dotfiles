-- markdown-preview.nvim needs its bundled app installed after install/update
vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    local data = ev.data
    if data.spec.name == "markdown-preview.nvim" and (data.kind == "install" or data.kind == "update") then
      if not data.active then
        vim.cmd.packadd("markdown-preview.nvim")
      end
      vim.fn["mkdp#util#install"]()
    end
  end,
})

-- Register our core plugin suite using 0.12's native package manager
vim.pack.add({
  -- Mini.nvim (Comprehensive module library)
  "https://github.com/echasnovski/mini.nvim",

  -- LSP Support
  "https://github.com/neovim/nvim-lspconfig",

  -- Colorscheme
  "https://github.com/folke/tokyonight.nvim",

  -- Markdown preview in the browser
  "https://github.com/iamcco/markdown-preview.nvim",
})

