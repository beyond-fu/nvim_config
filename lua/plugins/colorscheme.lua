return {
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "habamax" },
  },
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
}
