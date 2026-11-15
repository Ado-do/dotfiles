return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = { enabled = false },
    servers = {
      -- markdown diagnostics and quick fixes; config: ~/.config/rumdl/rumdl.toml
      -- marksman (lang.markdown extra) owns navigation; drop rumdl's overlapping
      -- providers so symbols, references, hover, etc. aren't listed twice
      rumdl = {
        on_init = function(client)
          local caps = client.server_capabilities
          if not caps then
            return
          end
          for _, provider in ipairs({
            "completionProvider",
            "definitionProvider",
            "documentSymbolProvider",
            "hoverProvider",
            "referencesProvider",
            "renameProvider",
            "workspaceSymbolProvider",
          }) do
            caps[provider] = nil
          end
        end,
      },
      -- installed by mason only as conform formatters (see conform.lua); don't auto-start their LSPs
      oxfmt = { enabled = false },
      biome = { enabled = false },
      -- lang.docker adds it, but it only attaches to the "yaml.docker-compose" filetype and compose.yaml is
      -- detected as plain yaml; yamlls + SchemaStore (lang.yaml) already validates compose files
      docker_compose_language_service = { enabled = false },
    },
  },
}
