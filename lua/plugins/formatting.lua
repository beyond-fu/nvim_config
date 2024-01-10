return {
  {
    "stevearc/conform.nvim",
    enabled = false,
  },
  -- none-ls formatting tool(null-ls)
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        -- nls.builtins.formatting.yamlfmt,
        nls.builtins.diagnostics.shellcheck, --static shell lint
        nls.builtins.formatting.shfmt, -- shell formatting
        nls.builtins.diagnostics.checkmake, -- Makefile lint
        nls.builtins.formatting.autopep8.with({
          extra_args = { "--max-line-length", "120" },
        }), -- python formatting
        nls.builtins.diagnostics.markdownlint,
        nls.builtins.formatting.markdownlint,
        nls.builtins.hover.printenv.with({
          filetypes = { "sh", "dosbatch", "ps1", "make" },
        }),
        nls.builtins.formatting.asmfmt,
        -- cspell: spell checker linter and code action, I think codespell is simple and crude
        -- nls.builtins.diagnostics.cspell.with({
        --     disabled_filetypes = { "lua", "c", "cpp", "make" },
        -- }),
        -- nls.builtins.code_actions.cspell.with({
        --     config = {
        --         find_json = function(cwd)
        --             return vim.fn.expand(cwd .. "/cspell.json")
        --         end,
        --     },
        --     on_success = function(cspell_config_file, params)
        --         -- format the cspell config file
        --         os.execute(
        --             string.format(
        --                 "cat %s | jq -S '.words |= sort' | tee %s > /dev/null",
        --                 cspell_config_file,
        --                 cspell_config_file
        --             )
        --         )
        --     end,
        --     disabled_filetypes = { "lua", "c", "cpp" },
        -- }),
      })
    end,
  },
}
