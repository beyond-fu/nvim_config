return {
    -- Tabnine(free version: line completion)
    {
        "nvim-cmp",
        dependencies = {
            {
                "tzachar/cmp-tabnine",
                config = function(_, opts)
                    local tabnine = require("cmp_tabnine.config")
                    tabnine:setup(
                        {
                            max_lines = 1000,
                            max_num_results = 20,
                            sort = true,
                            run_on_every_keystroke = true,
                            snippet_placeholder = '..',
                            ignored_file_types = {
                                -- default is not to ignore
                                -- uncomment to ignore in lua:
                                -- lua = true
                            },
                            show_prediction_strength = false
                        }
                    )
                end,
            },
        },
        ---@param opts cmp.ConfigSchema
        opts = function(_, opts)
            local cmp = require("cmp")

            table.insert(opts.sources, 1, { name = "cmp_tabnine", group_index = 2 })

            local confirm = opts.mapping["<CR>"]
            local confirm_tabnine = cmp.mapping.confirm({
                select = true,
                behavior = cmp.ConfirmBehavior.Replace,
            })

            opts.mapping = vim.tbl_extend("force", opts.mapping, {
                ["<CR>"] = function(...)
                    local entry = cmp.get_selected_entry()
                    if entry and entry.source.name == "cmp_tabnine" then
                        return confirm_tabnine(...)
                    end
                    return confirm(...)
                end,
            })
            opts.sorting = {
                priority_weight = 2,
                comparators = {
                    require("cmp_tabnine.compare"),
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.score,
                    cmp.config.compare.recently_used,
                    cmp.config.compare.locality,
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            }
        end,
    },
    -- Chatgpt
    {
        "jackMort/ChatGPT.nvim",
        keys = {
            { "<leader>pe", "<cmd>ChatGPTEditWithInstructions<CR>", desc = "Edit with instructions" },
            { "<leader>pc", "<cmd>ChatGPT<CR>",                     desc = "Chat" },
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

    -- use copilot.vim
    {
        "github/copilot.vim",
        cmd = "Copilot",
        build = ":Copilot setup",
        keys = {
            { "<leader>Ce", "<cmd>Copilot enable<CR>", desc = "Copilot enable" },
        },
    },
}
