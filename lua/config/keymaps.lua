-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "n", "v" }, "q", "<Nop>", { noremap = true, silent = true, desc = "map recording key(q) to <Nop>" })
vim.keymap.set({ "i", "n", "v" }, "jk", "<ESC>", { noremap = true, silent = true })
vim.keymap.set("t", "jk", "<C-\\><C-N>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "j", "<Up>", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "k", "<Down>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-j>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.del("t", "<C-l>")
vim.keymap.set("n", "<A-k>", "<cmd>m .+1<cr>==", { noremap = true, desc = "Move down", silent = true })
vim.keymap.set("n", "<A-j>", "<cmd>m .-2<cr>==", { noremap = true, desc = "Move up", silent = true })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down", silent = true })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up", silent = true })
vim.keymap.set("v", "<A-k>", ":m '>+1<cr>gv=gv", { desc = "Move down", silent = true })
vim.keymap.set("v", "<A-j>", ":m '<-2<cr>gv=gv", { desc = "Move up", silent = true })
vim.keymap.set({ "i", "n" }, "jk", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch", noremap = false })
vim.keymap.set("n", "<F8>", "<cmd>SymbolsOutline<CR>", { noremap = true, silent = true, desc = "Toggle outline" })
vim.keymap.set("n", "dc", "cc<ESC>", { noremap = true, silent = true, desc = "Delete current line&Insert" })
vim.keymap.set(
    { "n" },
    "<A-\\>",
    "<cmd>2ToggleTerm direction=vertical size=50<CR>",
    { noremap = true, silent = true, desc = "Open terminal vertical" }
)
vim.keymap.set("n", "<C-w>m", function()
    vim.cmd([[wincmd |]])
    vim.cmd([[wincmd _]])
end, { noremap = false, desc = "Window Max" })
-- vim.keymap.set("n", "<C-w>_", "<cmd>WindowsMaximizeVertically<CR>", { noremap = true, desc = "Window Max Vertical" })
-- vim.keymap.set("n", "<C-w>|", "<cmd>WindowsMaximizeHorizontally<CR>", { noremap = true, desc = "Window Max Horizontal" })
-- vim.keymap.set("n", "<C-w>=", "<cmd>WindowsEqualize<CR>", { noremap = true, desc = "Window Max Equal" })

-- fold
vim.keymap.set("n", "zm", "zm", { noremap = true, desc = "Fold more       (global)" })
vim.keymap.set("n", "zM", "zM", { noremap = true, desc = "Close all folds (global)" })
vim.keymap.set("n", "zc", "zc", { noremap = true, desc = "Close fold       (cursor)" })
vim.keymap.set("n", "zC", "zC", { noremap = true, desc = "Close all folds  (cursor)" })
-- fold preview
vim.api.nvim_create_autocmd({ "BufReadPost" }, {
    callback = function()
        if vim.fn.exists("loaded_ufo") then
            vim.keymap.set('n', 'K', function()
                local winid = require('ufo').peekFoldedLinesUnderCursor()
                if not winid then
                    vim.lsp.buf.hover()
                end
            end, { desc = "Hover with UFO" })
        else
            vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Hover" })
        end
    end
})
-- unfold
vim.keymap.set("n", "zo", "zo", { noremap = true, desc = "Open fold       (cursor)" })
vim.keymap.set("n", "zO", "zO", { noremap = true, desc = "Open all folds  (cursor)" })
vim.keymap.set("n", "zr", "zr", { noremap = true, desc = "Fold less       (global)" })
vim.keymap.set("n", "zR", "zR", { noremap = true, desc = "Open all folds  (global)" })

-- Tabnine(not official Tabnine plugin, rather than cmp-tabnine)
vim.keymap.set("n", "<leader>th", "<cmd>CmpTabnineHub", { desc = "Tabnine Hub" })
-- vim.keymap.set("n", "<leader>ts", "<cmd>TabnineStatus<CR>", { desc = "Tabnine status" })
-- vim.keymap.set("n", "<leader>td", "<cmd>TabnineDisable<CR>", { desc = "Tabnine disable" })
-- vim.keymap.set("n", "<leader>th", "<cmd>TabnineHub<CR>", { desc = "Tabnine hub" })

-- Copilot keymaps
vim.keymap.set("n", "<leader>Cp", "<cmd>Copilot panel<CR>", { desc = "Copilot panel", silent = true })
vim.keymap.set("n", "<leader>Cv", "<cmd>Copilot version<CR>", { desc = "Copilot version", silent = true })
vim.keymap.set("n", "<leader>Cs", "<cmd>Copilot status<CR>", { desc = "Copilot status", silent = true })
vim.keymap.set("n", "<leader>Cr", "<cmd>Copilot restart<CR>", { desc = "Copilot restart", silent = true })
vim.keymap.set("n", "<leader>Cd", "<cmd>Copilot disable<CR>", { desc = "Copilot disable", silent = true })
vim.keymap.set("i", "<C-j>", "copilot#Accept('<CR>')",
    { expr = true, desc = "Accept copilot suggestions", noremap = true, silent = true, replace_keycodes = false })

-- nvim-dap
vim.keymap.set("n", "<leader>dd", function() require("dap").clear_breakpoints() end, { desc = "delete all breakpoints" })
