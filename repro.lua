-- Minimal `init.lua` to reproduce an issue. Save as `repro.lua` and run with `nvim -u repro.lua`

-- sets std paths to use .repro and bootstraps lazy
local function bootstrap(root) -- DO NOT change the paths
  for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
  end
  local lazypath = root .. "/plugins/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", lazypath })
  end
  vim.opt.rtp:prepend(vim.env.LAZY or lazypath)
end
local root = vim.fn.fnamemodify("./.repro", ":p")
bootstrap(root)

-- recognize systemverilog
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufRead" }, {
  pattern = { "*.vh", "*.svh" },
  command = "set filetype=systemverilog",
})

-- install plugins
local plugins = {
  -- optional: reduce the number of plugins needed to reproduce the problem
  { "abeldekat/lazyflex.nvim", version = "*", import = "lazyflex.hook", opts = {} },
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  -- {
  --   "mason.nvim",
  --   opts = { ensure_installed = { "verible" } },
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- manage integration of LSP and neovim(upper level, because of the existence of Mason)
      servers = {
        -- use svlangserver to gd, formatting(verible), hover
        -- svlangserver hover has a bug, `define macro hover` will not work after saving current file.
        -- Must save the `define macro file` again to make `define macro hover` work again.
        -- veridian = {
        --   cmd = { "veridian" },
        --   filetypes = { "systemverilog", "verilog" },
        --   -- root_dir = require("lspconfig.util").root_pattern("veridian.yml", ".git"),
        --   single_file_support = true,
        -- },
        svlangserver = {
          cmd = { "svlangserver" },
          filetypes = { "verilog", "systemverilog" },
          -- root_dir = require("lspconfig.util").root_pattern("veridian.yml", ".git"),
          settings = {
            systemverilog = {
              includeIndexing = { "*.{v,vh,sv,svh}", "**/*.{v,vh,sv,svh}" },
              disableLinting = true,
              disableCompletionProvider = true,
              disableHoverProvider = false,
              disableSignatureHelpProvider = true,
              -- linter = "verilator",
              -- cannot disable formatting for svlangserver, so do not format with veridian
              formatCommand = "verible-verilog-format --indentation_spaces=4",
            },
          },
          single_file_support = true,
        },
        -- verible = {
        --   cmd = { "verible-verilog-ls" },
        --   filetypes = { "systemverilog", "verilog" },
        --   -- root_dir = require("lspconfig.util").root_pattern(".git"),
        --   single_file_support = true,
        -- },
      },
      -- setup = {
      --   veridian = function()
      --     require("lazyvim.util").lsp.on_attach(function(client, _)
      --       if client.name == "veridian" then
      --         -- disable hover of veridian
      --         client.server_capabilities.hoverProvider = false
      --       end
      --     end)
      --   end,
      -- },
      {
        "conform.nvim",
        cond = true,
      },
    },
  },
}
require("lazy").setup(plugins, {
  root = root .. "/plugins",
})
