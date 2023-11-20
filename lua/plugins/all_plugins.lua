return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "habamax" },
  },
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
        -- use veridian to dot-completion, syntax lint(slang and verible), veridian cannot hover define macro
        veridian = {
          cmd = { "veridian" },
          filetypes = { "systemverilog", "verilog" },
          root_dir = require("lspconfig.util").root_pattern("veridian.yml", ".git"),
          single_file_support = true,
        },
        -- use svlangserver to gd, formatting(verible), hover
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
              -- cannot disable formatting for svlangserver, so do not format with veridian
              formatCommand = "verible-verilog-format --indentation_spaces=4",
            },
          },
          single_file_support = true,
        },
        -- verible = {
        --     cmd = { "verible-verilog-ls" },
        --     filetypes = { "systemverilog", "verilog" },
        --     root_dir = require("lspconfig.util").root_pattern(".git"),
        --     single_file_support = true,
        -- },
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
  -- nvim-ufo, code fold tool
  {
    "kevinhwang91/nvim-ufo",
    dependencies = {
      "kevinhwang91/promise-async",
      {
        "luukvbaal/statuscol.nvim",
        config = function()
          local builtin = require("statuscol.builtin")
          require("statuscol").setup({
            relculright = true,
            segments = {
              { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
              { text = { "%s" }, click = "v:lua.ScSa" },
              { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
            },
          })
        end,
      },
    },
    event = { "BufRead" },
    config = function()
      vim.g.loaded_ufo = 1
      local ftMap = {
        vim = "indent",
        python = { "indent" },
        git = "",
      }
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end
      require("ufo").setup({
        open_fold_hl_timeout = 100,
        close_fold_kinds = { "imports", "comment" },
        fold_virt_text_handler = handler, -- customize the function about how to display folded content
        preview = {
          win_config = {
            border = { "", "─", "", "", "", "─", "", "" },
            winhighlight = "Normal:Folded",
            winblend = 0,
          },
          mappings = {
            scrollU = "<C-u>",
            scrollD = "<C-d>",
            jumpTop = "[",
            jumpBot = "]",
          },
        },
        provider_selector = function(bufnr, filetype, buftype)
          -- if you prefer treesitter provider rather than lsp,
          -- return ftMap[filetype] or {'treesitter', 'indent'}
          return ftMap[filetype]
        end,
      })
    end,
  },
  -- see images in neovim with ascii
  {
    "samodostal/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim", { "m00qek/baleia.nvim", tag = "v1.3.0" } },
    ft = { "pic" }, -- filetype "pic" see autocmds.lua
    config = function()
      require("image").setup({})
    end,
  },
  --which-key
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>u"] = { name = "+ui/undo-tree" },
        ["<leader>P"] = { name = "ChatGPT" },
        ["<leader>t"] = { name = "Tabnine" },
        ["<leader>C"] = { name = "Copilot" },
      },
      window = {
        border = "single",
      },
    },
  },
  -- config scroll animation
  {
    "echasnovski/mini.animate",
    opts = function()
      -- don't use animate when scrolling with the mouse
      local mouse_scrolled = false
      for _, scroll in ipairs({ "Up", "Down" }) do
        local key = "<ScrollWheel" .. scroll .. ">"
        vim.keymap.set({ "", "i" }, key, function()
          mouse_scrolled = true
          return key
        end, { expr = true })
      end

      local animate = require("mini.animate")
      return {
        cursor = { enable = false },
        resize = {
          timing = animate.gen_timing.linear({ duration = 100, unit = "total" }),
        },
        scroll = {
          timing = animate.gen_timing.linear({ duration = 150, unit = "total" }),
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              if mouse_scrolled then
                mouse_scrolled = false
                return false
              end
              return total_scroll > 1
            end,
          }),
        },
      }
    end,
  },
  -- colorizer
  {
    "norcalli/nvim-colorizer.lua",
    keys = {
      { "<leader>cp", "<cmd>ColorizerToggle<CR>", desc = "Color Preview(Colorizer)" },
    },
  },
  -- terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", "<Cmd>execute v:count . 'ToggleTerm '<CR>", mode = { "i", "n" } },
    },
    config = true,
    opts = {
      size = 20,
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_filetypes = {},
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
    },
  },
  -- function outline plugin
  {
    "simrat39/symbols-outline.nvim",
    config = function()
      require("symbols-outline").setup({})
    end,
  },
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local nls = require("null-ls")
      opts.root_dir = opts.root_dir
        or require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git")
      opts.sources = vim.list_extend(opts.sources or {}, {
        nls.builtins.formatting.yamlfmt,
        nls.builtins.diagnostics.shellcheck, --static shell lint
        nls.builtins.formatting.shfmt, -- shell formatting
        nls.builtins.diagnostics.checkmake, -- Makefile lint
        nls.builtins.formatting.autopep8, -- python formatting
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
  {
    -- current file explore: neo-tree
    "nvim-neo-tree/neo-tree.nvim",
    -- enabled = false,
    opts = {
      window = {
        width = 30,
      },
      filesystem = {
        window = {
          mappings = {
            ["i"] = "show_fs_stat",
          },
        },
        commands = {
          show_fs_stat = function(state)
            local utils = require("utils.utils")
            local node = state.tree:get_node()
            local stat = vim.loop.fs_stat(node.path)
            local str = ""
            str = str .. string.format("Type: %s\n", stat.type)
            str = str .. string.format("Size: %s\n", utils.format_size(stat.size))
            str = str .. string.format("Time: %s\n", utils.format_time(stat.mtime.sec))
            str = str .. string.format("Mode: %s\n", utils.format_mode(stat.mode, stat.type))
            vim.notify(str)
          end,
        },
      },
    },
  },
  -- disable nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    enabled = false,
    version = "*",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "<leader>e",
        function()
          require("nvim-tree.api").tree.toggle({
            path = require("lazyvim.util").get_root(),
            -- current_window = true,
            -- focus = true
          })
        end,
        desc = "Explorer NvimTree",
        silent = true,
      },
    },
    config = function()
      require("nvim-tree").setup({
        sort_by = "case_sensitive",
        disable_netrw = true,
        hijack_cursor = true,
        diagnostics = {
          enable = false,
        },
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
      })
    end,
  },
  -- set notify background color
  {
    "rcarriga/nvim-notify",
    enabled = false,
    -- used for opacity
    -- config = function()
    --     require("notify").setup({
    --         -- background_colour = "#000000",
    --     })
    -- end,
    opts = {
      timeout = 4000,
      stages = "static",
    },
  },
  -- noice filter out "No information available"
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
    end,
  },
  -- current comment tool
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        ignore = "^$",
      })
    end,
  },
  -- not use mini.commment
  {
    "echasnovski/mini.comment",
    enabled = false,
  },
  -- theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    enabled = false,
    lazy = true,
    config = function()
      require("catppuccin").setup({
        flavour = "macchiato",
        -- transparent_background = true,
      })
    end,
  },
  -- current theme
  {
    "echasnovski/mini.hues",
    version = false,
    config = function()
      require("mini.hues").setup({
        background = "#0E1F25",
        foreground = "#c0c8cc",
        n_hues = 8,
        satuation = "medium",
        accent = "fg",
        plugin = { default = true },
      })
      vim.g.terminal_color_8 = "#767676"
    end,
  },
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- undo tree
      "debugloop/telescope-undo.nvim",
    },
    keys = {
      { "<leader>uu", "<cmd>Telescope undo<CR>", desc = "Open UndoTree" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            n = {
              ["j"] = function(...)
                return require("telescope.actions").move_selection_previous(...)
              end,
              ["k"] = function(...)
                return require("telescope.actions").move_selection_next(...)
              end,
              ["<C-j>"] = function(...)
                return require("telescope.actions").preview_scrolling_up(...)
              end,
              ["<C-k>"] = function(...)
                return require("telescope.actions").preview_scrolling_down(...)
              end,
              ["q"] = function(...)
                return require("telescope.actions").close(...)
              end,
            },
            i = {
              ["<C-j>"] = function(...)
                return require("telescope.actions").preview_scrolling_up(...)
              end,
              ["<C-k>"] = function(...)
                return require("telescope.actions").preview_scrolling_down(...)
              end,
            },
          },
        },
        -- "undo" compares two modifications next to each other using delta
        extensions = {
          undo = {
            use_delta = true,
            side_by_side = false, -- unnecessary, but can be overrided by .gitconfig
            layout_strategy = "horizontal",
            layout_config = {
              height = 0.95,
              width = 0.9,
              preview_width = 0.6,
            },
            mappings = {
              i = {
                -- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
                -- you want to replicate these defaults and use the following actions. This means
                -- installing as a dependency of telescope in it's `requirements` and loading this
                -- extension from there instead of having the separate plugin definition as outlined
                -- above.
                ["<CR>"] = require("telescope-undo.actions").restore,
                ["<C-y>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
              },
              n = {
                ["<CR>"] = require("telescope-undo.actions").restore,
                ["<C-y>"] = require("telescope-undo.actions").yank_additions,
                ["<C-d>"] = require("telescope-undo.actions").yank_deletions,
              },
            },
          },
        },
      })
      require("telescope").load_extension("undo")
      -- optional: vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    end,
  },
  {
    "folke/todo-comments.nvim",
    opts = {
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        comments_only = true,
      },
      keywords = {
        DOUBT = {
          icon = "",
          color = "#3498DB",
        },
        FIXDONE = {
          icon = "",
          color = "#3CE416",
        },
        FEATURE = {
          icon = "",
          color = "#12F2B0",
        },
        DONE = {
          icon = "󰸡",
          color = "#A2ED43",
        },
        TODO = {
          icon = "",
          color = "info",
        },
      },
    },
  },
  -- markdown preview in chrome
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    config = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  -- disable Tab and S-Tab for LuaSnip
  -- {
  --     "L3MON4D3/LuaSnip",
  --     keys = function()
  --         return {}
  --     end,
  -- },
  -- add my own snippets to LuaSnip
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_lua").lazy_load({ paths = "~/nvim_config/lua/snippets/" })
      end,
    },
  },
  -- Trouble keymap
  {
    "folke/trouble.nvim",

    opts = {
      use_diagnostic_signs = true,
      action_keys = {
        previous = "j",
        next = "k",
      },
    },
  },
  -- Jump plugin, remove t and T keymap in flash.nvim, not use flit and leap
  {
    "folke/flash.nvim",
    keys = {
      -- Show diagnostics at target, without changing cursor position
      {
        "cd",
        mode = { "n", "x" },
        function()
          require("flash").jump({
            matcher = function(win)
              ---@param diag Diagnostic
              return vim.tbl_map(function(diag)
                return {
                  pos = { diag.lnum + 1, diag.col },
                  end_pos = { diag.end_lnum + 1, diag.end_col - 1 },
                }
              end, vim.diagnostic.get(vim.api.nvim_win_get_buf(win)))
            end,
            action = function(match, state)
              vim.api.nvim_win_call(match.win, function()
                vim.api.nvim_win_set_cursor(match.win, match.pos)
                vim.diagnostic.open_float()
              end)
              state:restore()
            end,
          })
        end,
        desc = "Flash diagnostics",
      },
      -- Continue flash last search
      {
        "t",
        mode = { "n", "x" },
        function()
          require("flash").jump({
            continue = true,
          })
        end,
        desc = "Continue Flash",
      },
      -- <c-s>(default key): toggles flash functionality on or off while using regular search
    },
    opts = {
      modes = {
        char = {
          keys = { "f", "F", ";", "," }, --delete 't' and 'T'
        },
        search = {
          -- disable flash in regular search by default, can switch by <c-s>
          enabled = false,
        },
      },
    },
  },

  -- translation plugin
  -- {
  --     "JuanZoran/Trans.nvim",
  --     build = function() require 'Trans'.install() end,
  --     keys = {
  --         { 'mt', mode = { 'n', 'x' }, '<Cmd>Translate<CR>', desc = ' Translate' },
  --         { 'mp', mode = { 'n', 'x' }, '<Cmd>TransPlay<CR>', desc = ' Auto Play' },
  --     },
  --     dependencies = { 'kkharji/sqlite.lua', },
  --     opts = {
  --         dir = "/home/fym/stardict.db",
  --     }
  -- },
}
