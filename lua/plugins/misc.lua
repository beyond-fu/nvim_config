return {
  -- see images in neovim with ascii
  {
    "samodostal/image.nvim",
    dependencies = { "nvim-lua/plenary.nvim", { "m00qek/baleia.nvim", tag = "v1.3.0" } },
    ft = { "pic" }, -- filetype "pic" see autocmds.lua
    config = function()
      require("image").setup({})
    end,
  },
  -- colorizer
  {
    "norcalli/nvim-colorizer.lua",
    keys = {
      { "<leader>cP", "<cmd>ColorizerToggle<CR>", desc = "Color Preview(Colorizer)" },
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
