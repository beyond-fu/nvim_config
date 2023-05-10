return {
    {
        "LazyVim/LazyVim",
        opts = { colorscheme = "tokyonight-night" },
    },
    -- nvim-lspconfig
    {
        "neovim/nvim-lspconfig",
        init = function()
            local keys = require("lazyvim.plugins.lsp.keymaps").get()
            keys[#keys + 1] = { "K", false }
        end,
        opts = {
            setup = {
                clangd = function(_, opts)
                    opts.capabilities.offsetEncoding = { "utf-16" }
                end,
            },
            servers = {
                pyright = {},
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
                            { text = { builtin.foldfunc },      click = "v:lua.ScFa" },
                            { text = { "%s" },                  click = "v:lua.ScSa" },
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
                ["<leader>p"] = { name = "ChatGPT" },
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
        "jose-elias-alvarez/null-ls.nvim",
        opts = function()
            local nls = require("null-ls")
            return {
                sources = {
                    nls.builtins.diagnostics.verilator,
                    nls.builtins.formatting.verible_verilog_format,
                    nls.builtins.diagnostics.shellcheck, --static shell lint
                    nls.builtins.formatting.shfmt,       -- shell formatting
                    nls.builtins.diagnostics.checkmake,  -- Makefile lint
                    nls.builtins.formatting.autopep8,    -- python formatting
                    nls.builtins.diagnostics.markdownlint,
                    nls.builtins.formatting.markdownlint,
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
                },
            }
        end,
    },
    {
        -- don't use neo-tree
        "nvim-neo-tree/neo-tree.nvim",
        -- enabled = false,
        opts = {
            window = {
                width = 30,
            },
        },
    },
    -- current file explore: nvim-tree
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
                silent = true
            }
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
        config = function()
            require("notify").setup({
                -- background_colour = "#000000",
            })
        end,
        opts = {
            timeout = 3000,
        },
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
    -- theme
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato",
                -- transparent_background = true,
            })
        end,
    },
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
            keywords = {
                DOUBT = {
                    icon = "",
                    color = "#3498DB",
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
    {
        "L3MON4D3/LuaSnip",
        keys = function()
            return {}
        end,
    },
}
