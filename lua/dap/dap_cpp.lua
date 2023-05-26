local dap = require("dap")

-- Adapter definition
dap.adapters.cppdbg = {
    id = "cppdbg",
    type = 'executable',
    command = "~/.local/share/nvim/mason/bin/OpenDebugAD7",
}
-- detailed configurations
dap.configurations.cpp = {
    {
        name = "Launch file",
        type = "cppdbg",
        request = "launch",
        program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        -- args = function()
        --     return vim.fn.input("args: ")
        -- end,
        stopAtEntry = true,
    },
}
