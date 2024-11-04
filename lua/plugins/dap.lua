return {
  -- dapui
  {
    "rcarriga/nvim-dap-ui",
    config = function(_, opts)
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup(opts)
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open({})
      end
      -- I do not want to close dapui when exe terminated, so comment below two function
      -- dap.listeners.before.event_terminated["dapui_config"] = function()
      --     dapui.close({})
      -- end
      -- dap.listeners.before.event_exited["dapui_config"] = function()
      --     dapui.close({})
      -- end
    end,
  },
  -- configure cpptools dap so that it can accept arguments
  {
    "jay-babu/mason-nvim-dap.nvim",
    opts = {
      handlers = {
        function(config)
          -- all sources with no handler get passed here
          -- Keep original functionality
          require("mason-nvim-dap").default_setup(config)
        end,
        cppdbg = function(config)
          config.configurations = {
            {
              name = "Launch file",
              type = "cppdbg",
              request = "launch",
              args = function()
                local args_string = vim.fn.input("Input arguments: ")
                return vim.split(args_string, " ")
              end,
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
              cwd = "${workspaceFolder}",
              stopAtEntry = true,
            },
            {
              name = "Attach to gdbserver :1234",
              type = "cppdbg",
              request = "launch",
              MIMode = "gdb",
              miDebuggerServerAddress = "localhost:1234",
              miDebuggerPath = "/usr/bin/gdb",
              cwd = "${workspaceFolder}",
              args = function()
                local args_string = vim.fn.input("Input arguments: ")
                return vim.split(args_string, " ")
              end,
              program = function()
                return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
              end,
            },
          }
          require("mason-nvim-dap").default_setup(config)
        end,
      },
    },
  },
}
