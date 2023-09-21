local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    -- bootstrap lazy.nvim
    -- stylua: ignore
    vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable",
        lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
    spec = {
        -- add LazyVim and import its plugins
        { "LazyVim/LazyVim",                                    import = "lazyvim.plugins" },
        -- import any extras modules here
        -- { import = "lazyvim.plugins.extras.lang.typescript" },
        -- { import = "lazyvim.plugins.extras.lang.json" },
        { import = "lazyvim.plugins.extras.ui.mini-animate" },
        { import = "lazyvim.plugins.extras.dap.core" },
        { import = "lazyvim.plugins.extras.coding.yanky" },
        { import = "lazyvim.plugins.extras.formatting.prettier" },
        -- import/override with your plugins
        { import = "plugins" },
        -- { import = "lazyvim.plugins.extras.coding.copilot" },
    },
    defaults = {
        -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
        -- If you know what falseyou're doing, you can set this to `true` to have all your custom plugins lazy-loaded by dfault.
        -- this `lazy` config option means: when true, by default lazy-leaded all your own pluggins(in config/plugins/all_plugins.lua),
        -- when false, all your own plugins will be loaded during startup(of course depending on youe config for each plugin)
        lazy = false,
        -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
        -- have outdated releases, which may break your Neovim install.
        version = false, -- always use the latest git commit
        -- version = "*", -- try installing the latest stable version for plugins that support semver
    },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = { enabled = false }, -- automatically check for plugin updates
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
                "gzip",
                -- "matchit",
                -- "matchparen",
                -- "netrwPlugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
-- set MatchParen highlight group(for matched brackets)
vim.api.nvim_set_hl(0, 'MatchParen', { bold = true, fg = "#ff9e64" })
vim.api.nvim_set_hl(0, 'Comment', { italic = true, ctermfg = 243, fg = "#767676" })
vim.api.nvim_set_hl(0, 'Keyword', { italic = true, ctermfg = 139, fg = "#af87af" })
-- Greying out the search area(Leap)
-- vim.api.nvim_set_hl(0, "LeapBackdrop", { link = "Comment" })
