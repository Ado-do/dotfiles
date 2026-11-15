-- True if the project around `ctx` uses a tool: one of `config_files` exists in a
-- parent directory, or a package.json up the tree lists `package` as a dependency
-- (any of them, so monorepo subpackages inherit the root's choice).
local function project_uses(ctx, package, config_files)
  if vim.fs.root(ctx.dirname, config_files) then
    return true
  end
  local pkgs = vim.fs.find("package.json", {
    path = ctx.dirname,
    upward = true,
    stop = vim.uv.os_homedir(),
    limit = math.huge,
  })
  for _, path in ipairs(pkgs) do
    local ok, pkg = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
    if ok and type(pkg) == "table" then
      for _, field in ipairs({ "dependencies", "devDependencies" }) do
        if type(pkg[field]) == "table" and pkg[field][package] then
          return true
        end
      end
    end
  end
  return false
end

-- JS/TS: use the formatter the project declares, falling back to prettier
local formatters_by_ft = {
  cpp = { "clang-format" },
  markdown = { "rumdl" }, -- config: ~/.config/rumdl/rumdl.toml
}
for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
  formatters_by_ft[ft] = { "oxfmt", "biome", "prettier", stop_after_first = true }
end

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = formatters_by_ft,
      formatters = {
        ["clang-format"] = {
          prepend_args = function()
            local config_path = vim.fn.expand("$HOME/.config/.clang-format")
            if vim.fn.filereadable(config_path) == 1 then
              return { "--style=file:" .. config_path }
            end
            return { "--style=LLVM" } -- Default fallback
          end,
        },
        -- without an .editorconfig shfmt indents with tabs; match the 4-space style instead
        shfmt = { prepend_args = { "-i", "4", "-ci" } },
        oxfmt = {
          condition = function(_, ctx)
            return project_uses(ctx, "oxfmt", { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" })
          end,
        },
        biome = {
          condition = function(_, ctx)
            return project_uses(ctx, "@biomejs/biome", { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" })
          end,
        },
      },
    },
  },
  -- Fallback binaries; the project's own node_modules/.bin copy is preferred when installed
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "oxfmt", "biome" } },
  },
}
