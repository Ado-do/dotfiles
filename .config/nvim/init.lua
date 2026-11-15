-- Core configuration
require("config.options")
require("plugins.init") -- Registers plugins with vim.pack.add
require("config.keymaps")
require("config.autocmds")
require("config.neovide")

-- Plugin setups. Report load failures instead of silently skipping.
local function load_plugin(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify(("Failed to load %s: %s"):format(module, err), vim.log.levels.WARN)
  end
end

load_plugin("plugins.mini")
load_plugin("plugins.lsp")
load_plugin("plugins.colorscheme")
