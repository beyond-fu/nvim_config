return {
  -- cmdline tools and lsp servers
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "clangd",
        "cpptools",
        "cspell",
        "json-lsp",
        "lua-language-server",
        "markdownlint",
        "shellcheck",
        "pyright",
        "autopep8",
        "shfmt",
      },
    },
  },
  -- nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "K", false }
    end,
    opts = {
      -- manage integration of LSP and neovim(upper level, because of the existence of Mason)
      servers = {
        pyright = {},
        -- use veridian to dot-completion, syntax lint(slang and verible), formatting(verible), veridian cannot hover define macro
        veridian = {
          cmd = { "veridian" },
          filetypes = { "systemverilog", "verilog" },
          root_dir = require("lspconfig.util").root_pattern("veridian.yml", ".git"),
          single_file_support = true,
        },
        -- use svlangserver to gd, hover
        -- svlangserver hover has a bug, `define macro hover` will not work after saving current file.
        -- Must save the `define macro file` again to make `define macro hover` work again.
        svlangserver = {
          cmd = { "svlangserver" },
          filetypes = { "verilog", "systemverilog" },
          root_dir = require("lspconfig.util").root_pattern("veridian.yml", ".git"),
          settings = {
            systemverilog = {
              includeIndexing = { "*.{v,vh,sv,svh}", "**/*.{v,vh,sv,svh}" },
              disableLinting = true,
              disableCompletionProvider = true,
              disableHoverProvider = false,
              disableSignatureHelpProvider = true,
              -- linter = "verilator",
              -- use `veridian` to format, disable `svlangserver` formatting by setting formatCommand to null
              -- formatCommand = "verible-verilog-format --indentation_spaces=4",
              formatCommand = "",
            },
          },
          single_file_support = true,
        },
        -- verible LSP not mature yet
        --[[ verible = {
          cmd = { "verible-verilog-ls" },
          filetypes = { "systemverilog", "verilog" },
          root_dir = require("lspconfig.util").root_pattern(".git"),
          single_file_support = true,
        }, ]]
      },
      -- detailed configurations of each LSP(bottom level)
      setup = {
        clangd = function(_, opts)
          opts.capabilities.offsetEncoding = { "utf-16" }
          opts.cmd = {
            "clangd",
            "--header-insertion=never",
            "--clang-tidy",
          }
        end,
        veridian = function()
          require("lazyvim.util").lsp.on_attach(function(client, _)
            if client.name == "veridian" then
              -- disable hover of veridian
              client.server_capabilities.hoverProvider = false
            end
          end)
        end,
      },
    },
  },
  -- nvim-cmp
  {
    "nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.sources = {
        { name = "luasnip" },
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "buffer", keyword_length = 5 },
        { name = "cmp_tabnine" },
      }
      -- opts.sources = {
      --   { name = "nvim_lsp", group_index = 2, priority = 3 },
      --   { name = "luasnip", group_index = 2, priority = 3 },
      --   { name = "path", group_index = 2, priority = 3 },
      --   { name = "buffer", group_index = 2, priority = 2, keyword_length = 3 },
      --   { name = "cmp_tabnine", group_index = 2, priority = 2 },
      -- }
      opts.sorting = {
        priority_weight = 2.0,
        comparators = {
          cmp.config.compare.recently_used,
          cmp.config.compare.locality,
          cmp.config.compare.offset,
          cmp.config.compare.exact,
          cmp.config.compare.score,
          cmp.config.compare.kind,
          cmp.config.compare.sort_text,
          cmp.config.compare.length,
          cmp.config.compare.order,
        },
      }
    end,
  },
  {
    "tzachar/cmp-tabnine",
    event = "InsertEnter",
    opts = {
      max_lines = 1000, -- how many lines used to predict for TabNine
      max_num_results = 5, --how many results to return
      sort = true, -- Sort results by returned priority
      run_on_every_keystroke = true,
      snippet_placeholder = "..",
      ignored_file_types = {
        -- default is not to ignore
        -- uncomment to ignore in lua:
        -- lua = true
      },
      show_prediction_strength = false,
    },
  },
  -- Tabnine(free version: line completion)
  -- {
  --   "nvim-cmp",
  --   dependencies = {
  --     {
  --       "tzachar/cmp-tabnine",
  --       config = function(_, opts)
  --         local tabnine = require("cmp_tabnine.config")
  --         tabnine:setup({
  --           max_lines = 1000,
  --           max_num_results = 20,
  --           sort = true,
  --           run_on_every_keystroke = true,
  --           snippet_placeholder = "..",
  --           ignored_file_types = {
  --             -- default is not to ignore
  --             -- uncomment to ignore in lua:
  --             -- lua = true
  --           },
  --           show_prediction_strength = false,
  --         })
  --       end,
  --     },
  --   },
  --   ---@param opts cmp.ConfigSchema
  --   opts = function(_, opts)
  --     local cmp = require("cmp")
  --     -- Make the priority of Luasnip higher than LSP
  --     local luasnip = "luasnip"
  --     local lsp = "nvim_lsp"
  --     local index1, index2
  --     for i, item in ipairs(opts.sources) do
  --       if item.name == luasnip then
  --         index1 = i
  --       end
  --       if item.name == lsp then
  --         index2 = i
  --       end
  --     end
  --     if index1 and index2 then
  --       local temp = opts.sources[index1]
  --       opts.sources[index1] = opts.sources[index2]
  --       opts.sources[index2] = temp
  --     end

  --     -- Insert cmp_tabnine element
  --     table.insert(opts.sources, 1, { name = "cmp_tabnine", group_index = 2 })

  --     local confirm = opts.mapping["<CR>"]
  --     local confirm_tabnine = cmp.mapping.confirm({
  --       select = true,
  --       behavior = cmp.ConfirmBehavior.Replace,
  --     })

  --     opts.mapping = vim.tbl_extend("force", opts.mapping, {
  --       ["<CR>"] = function(...)
  --         local entry = cmp.get_selected_entry()
  --         if entry and entry.source.name == "cmp_tabnine" then
  --           return confirm_tabnine(...)
  --         end
  --         return confirm(...)
  --       end,
  --     })
  --     opts.sorting = {
  --       priority_weight = 2,
  --       comparators = {
  --         require("cmp_tabnine.compare"),
  --         cmp.config.compare.offset,
  --         cmp.config.compare.exact,
  --         cmp.config.compare.score,
  --         cmp.config.compare.recently_used,
  --         cmp.config.compare.locality,
  --         cmp.config.compare.kind,
  --         cmp.config.compare.sort_text,
  --         cmp.config.compare.length,
  --         cmp.config.compare.order,
  --       },
  --     }
  --   end,
  -- },
}
