return {
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
  -- current file explore: neo-tree
  {
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
  -- nvim-ufo, code fold tool
  {
    "kevinhwang91/nvim-ufo",
    commit = "1c3eb7e3980246c432a037acbead2f0b0f0e2fa5",
    dependencies = {
      "kevinhwang91/promise-async",
      -- {
      --   "luukvbaal/statuscol.nvim",
      --   config = function()
      --     local builtin = require("statuscol.builtin")
      --     require("statuscol").setup({
      --       relculright = true,
      --       segments = {
      --         { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
      --         { text = { "%s" }, click = "v:lua.ScSa" },
      --         { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
      --       },
      --     })
      --   end,
      -- },
    },
    event = { "BufReadPost" },
    config = function()
      vim.g.loaded_ufo = 1
      local ftMap = {
        vim = "indent",
        python = { "indent" },
        git = "",
      }
      local handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
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
  -- not use mini.commment
  {
    "echasnovski/mini.comment",
    enabled = false,
  },
  -- current comment tool
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({ ignore = "^$" })
      local ft = require("Comment.ft")
      ft.verilog = { "//%s", "/*%s*/" }
      ft.systemverilog = { "//%s", "/*%s*/" }
    end,
  },
  -- use copilot.vim
  {
    "github/copilot.vim",
    cmd = "Copilot",
    build = ":Copilot setup",
    keys = {
      { "<leader>Ce", "<cmd>Copilot enable<CR>", desc = "Copilot enable" },
    },
  },
  -- copilot.lua(in lazy.lua) is slow to load, use copilot.vim
  -- {
  --     "zbirenbaum/copilot.lua",
  --     config = function()
  --         require('copilot').setup({
  --             panel = {
  --                 enabled = true,
  --                 auto_refresh = false,
  --                 keymap = {
  --                     jump_prev = "[[",
  --                     jump_next = "]]",
  --                     accept = "<CR>",
  --                     refresh = "gr",
  --                     open = "<M-CR>"
  --                 },
  --                 layout = {
  --                     position = "bottom", -- | top | left | right
  --                     ratio = 0.4
  --                 },
  --             },
  --             suggestion = {
  --                 enabled = true,
  --                 auto_trigger = false,
  --                 debounce = 75,
  --                 keymap = {
  --                     accept = "<M-l>",
  --                     accept_word = false,
  --                     accept_line = false,
  --                     next = "<M-]>",
  --                     prev = "<M-[>",
  --                     dismiss = "<C-]>",
  --                 },
  --             },
  --             filetypes = {
  --                 yaml = false,
  --                 markdown = false,
  --                 help = false,
  --                 gitcommit = false,
  --                 gitrebase = false,
  --                 hgcommit = false,
  --                 svn = false,
  --                 cvs = false,
  --                 ["."] = false,
  --             },
  --             copilot_node_command = 'node', -- Node.js version must be > 16.x
  --             server_opts_overrides = {},
  --         })
  --     end
  -- },
}
