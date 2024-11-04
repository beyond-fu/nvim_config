return {
  -- mini.move
  {
    "echasnovski/mini.move",
    opts = {
      mappings = {
        -- Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
        left = "<M-h>",
        right = "<M-l>",
        down = "",
        up = "",
        -- Move current line in Normal mode
        line_left = "<M-h>",
        line_right = "<M-l>",
        line_up = "",
        line_down = "",
      },
    },
  },
  -- minimap
  {
    "echasnovski/mini.map",
    -- version = false,
    config = function()
      local minimap = require("mini.map")
      require("mini.map").setup({
        integration = {
          minimap.gen_integration.builtin_search(),
          minimap.gen_integration.gitsigns(),
          minimap.gen_integration.diagnostic(),
        },
        symbols = {
          encode = nil,
          scroll_line = "",
          scroll_view = "",
        },
        window = {
          focusable = true,
          show_integration_count = false,
        },
      })
    end,
  },
  -- which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          mode = { "n", "v" },
          { "<leader>u", desc = "+ui/undo-tree" },
          { "<leader>P", desc = "ChatGPT" },
          { "<leader>t", desc = "Tabnine" },
          { "<leader>C", desc = "Copilot" },
        },
      },
      win = {
        border = "single",
      },
    },
  },
  {
    "LunarVim/bigfile.nvim",
    event = "BufReadPre",
    config = function()
      local ft_lines_table = { verilog = 10000, systemverilog = 10000, yaml = 10000 }
      require("bigfile").setup({
        filesize = 1, -- MiB
        pattern = function(bufnr)
          local file_contents = vim.fn.readfile(vim.api.nvim_buf_get_name(bufnr))
          local file_lines = #file_contents
          local file_type = vim.filetype.match({ buf = bufnr })
          if ft_lines_table[file_type] and file_lines > ft_lines_table[file_type] then
            return true
          end
          return false
        end,
        features = {
          "indent_blankline",
          "illuminate",
          "lsp",
          "treesitter",
        },
      })
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
  {
    "folke/todo-comments.nvim",
    -- config = function()
    --   local conf = require("todo-comments.config")
    --   for k, v in pairs(conf) do
    --     print(k, v)
    --   end
    -- end,
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
  -- Chatgpt
  {
    "jackMort/ChatGPT.nvim",
    keys = {
      { "<leader>Pe", "<cmd>chatgpteditwithinstructions<cr>", desc = "edit with instructions" },
      { "<leader>Pc", "<cmd>ChatGPT<CR>", desc = "Chat" },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("chatgpt").setup({
        -- yank_register = "+",
        -- edit_with_instructions = {
        --     diff = false,
        --     keymaps = {
        --         accept = "<C-y>",
        --         toggle_diff = "<C-d>",
        --         toggle_settings = "<C-o>",
        --         cycle_windows = "<Tab>",
        --         use_output_as_input = "<C-i>",
        --     },
        -- },
        chat = {
          keymaps = {
            close = { "<C-c>" },
            --         yank_last = "<C-y>",
            --         yank_last_code = "<C-k>",
            --         scroll_up = "<C-u>",
            --         scroll_down = "<C-d>",
            --         toggle_settings = "<C-o>",
            --         new_session = "<C-n>",
            --         cycle_windows = "<Tab>",
            --         select_session = "<Space>",
            --         rename_session = "r",
            --         delete_session = "d",
          },
        },
        popup_input = {
          -- prompt = "  ", -- do not work, don't know why
          submit = "<C-CR>",
        },
      })
    end,
  },
}
