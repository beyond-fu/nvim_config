return {
  -- disable nvim-notify
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
      opts.presets.lsp_doc_border = true
    end,
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
        cursor = {
          enable = false,
        },
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
  -- {
  --   "karb94/neoscroll.nvim",
  --   enabled=false,
  --   config = function()
  --     require("neoscroll").setup({
  --       mappings = {
  --         "<C-u>",
  --         "<C-d>",
  --         "<C-b>",
  --         "<C-f>",
  --         "<C-y>",
  --         "<C-e>",
  --         "zt",
  --         "zz",
  --         "zb",
  --       },
  --     })
  --   end,
  -- },
}
