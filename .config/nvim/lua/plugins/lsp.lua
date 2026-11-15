local lsp = vim.lsp

-- Diagnostics (0.12 ships virtual_text/severity_sort disabled)
vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  severity_sort = true,
})

-- Shared LSP Keybindings & Autocmds on client connection
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local opts = { buffer = bufnr }

    -- Navigation (grr/gri/grn/gra/grt, [d/]d and <C-w>d are Neovim 0.12 defaults)
    vim.keymap.set("n", "gd", lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to Definition" }))
    vim.keymap.set("n", "gD", lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to Declaration" }))

    vim.keymap.set("n", "<leader>f", function() lsp.buf.format({ async = true }) end, vim.tbl_extend("force", opts, { desc = "Format Document" }))

    -- Completion popup comes from 'autocomplete' + "o" in 'complete'; enabling the
    -- client here applies snippets and additional text edits on accept.
    lsp.completion.enable(true, args.data.client_id, bufnr)
  end,
})

-- Server-specific overrides; vim.lsp.config merges into nvim-lspconfig's defaults
lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--header-insertion=never" },
})

lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.pack.get({ "mini.nvim" }, { info = false })[1].path,
        },
      },
    },
  },
})

-- Enable servers dynamically if their executables are present on the system path
local servers = { "clangd", "pyright", "rust_analyzer", "gopls", "ts_ls", "html", "cssls", "lua_ls" }

for _, name in ipairs(servers) do
  local cmd = lsp.config[name].cmd
  if type(cmd) == "table" and vim.fn.executable(cmd[1]) == 1 then
    lsp.enable(name)
  end
end
