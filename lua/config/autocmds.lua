-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufRead" }, {
    pattern = { "*.jpeg", "*.jpg", "*.png", "*.bmp", "*.webp", "*.tiff", "*.tif", "*.gif", },
    command = "set filetype=pic",
})

-- must open below when not use nvim-ufo
-- vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd", "BufRead" }, {
--     callback = function()
--         vim.o.syntax = vim.o.filetype
--     end
-- })
