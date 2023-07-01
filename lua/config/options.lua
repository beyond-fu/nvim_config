-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tab
vim.opt.tabstop = 4      -- number of visual spaces per TAB
vim.opt.softtabstop = 4  -- number of spacesin tab when editing
vim.opt.shiftwidth = 4   -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI configs
vim.opt.number = true         -- show absolute number
vim.opt.relativenumber = true -- add numbers to each line on the left side
vim.opt.timeoutlen = 80
-- for markdown-preview
vim.g.mkdp_theme = "light"
vim.o.scrolloff = 10
-- t/T of flit is same as f/F but with offset -1/1

-- disable netrw
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

vim.o.winwidth = 10
vim.o.winminwidth = 10
vim.o.equalalways = false
-- Add library path(just for neovim, not LSP)
vim.opt.path = vim.opt.path + "/usr/lib/gcc/x86_64-linux-gnu/11/include/"

-- code folding tool
-- vim.opt.foldmethod = "syntax" -- use this when disable ufo plugin
vim.opt.foldcolumn = '1' -- '0' is not bad
vim.opt.foldlevel = 99   -- Using ufo provider need a large value, feel free to decrease the value
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Copilot
vim.g.copilot_proxy = "localhost:7890"
vim.g.copilot_no_tab_map = true
