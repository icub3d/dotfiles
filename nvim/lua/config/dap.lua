return function()
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup()

  -- import remap for keybindings.
  local remap = require('remap')
  local nnoremap = remap.nnoremap

  -- keybindings
  nnoremap('<leader>dc', function()
    dap.continue()
    dapui.open()
  end)
  nnoremap('<leader>dq', function()
    dap.close()
    dapui.close()
  end)
  nnoremap('<leader>dr', function() dap.run_to_cursor() end)
  nnoremap('<leader>db', function() dap.toggle_breakpoint() end)
  nnoremap('<leader>dB', function()
    dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
  end)
  nnoremap('<leader>do', function() dap.step_out() end)
  nnoremap('<leader>di', function() dap.step_into() end)
  nnoremap('<leader>dn', function() dap.step_over() end)
  nnoremap('<Up>', function() dap.step_out() end)
  nnoremap('<Down>', function() dap.step_into() end)
  nnoremap('<Right>', function() dap.step_over() end)

  -- C/C++/Rust
  dap.adapters.lldb = {
    type = 'executable',
    command = '/usr/bin/lldb-vscode', -- adjust as needed, must be absolute path
    name = 'lldb'
  }

  dap.configurations.cpp = {
    {
      name = 'Launch',
      type = 'lldb',
      request = 'launch',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},

      -- 💀
      -- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
      --
      --    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
      --
      -- Otherwise you might get the following error:
      --
      --    Error on launch: Failed to attach to the target process
      --
      -- But you should be aware of the implications:
      -- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
      -- runInTerminal = false,
    },
  }

  -- If you want to use this for Rust and C, add something like this:
  dap.configurations.c = dap.configurations.cpp
  dap.configurations.rust = dap.configurations.cpp
  -- If you want to be able to attach to running processes, add another configuration entry like described here:
  --
  -- https://github.com/mfussenegger/nvim-dap/wiki/Cookbook#pick-a-process
  --
  -- You can find more configurations options here:
  --
  -- https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
  -- https://github.com/llvm/llvm-project/blob/release/11.x/lldb/tools/lldb-vscode/package.json

  -- Python
  require('dap-python').setup('~/.python/bin/python')

  require('dap-go').setup()

  -- javascript
  dap.adapters.node2 = {
    type = 'executable',
    command = 'node',
    args = { os.getenv("HOME") .. '/dev/vscode-node-debug2/out/src/nodeDebug.js' },
  }
  dap.configurations.javascript = {
    {
      name = 'Launch',
      type = 'node2',
      request = 'launch',
      program = '${file}',
      cwd = vim.loop.cwd(),
      sourceMaps = true,
      protocol = 'inspector',
      console = 'integratedTerminal',
    },
    {
      -- For this to work you need to make sure the node process
      -- is started with the `--inspect` flag.
      name = 'Attach to process',
      type = 'node2',
      request = 'attach',
      processId = require('dap.utils').pick_process,
    },
  }

  dap.configurations.typescript = {
    {
      name = "ts-node (Node2 with ts-node)",
      type = "node2",
      request = "launch",
      cwd = vim.loop.cwd(),
      runtimeArgs = { "-r", "ts-node/register" },
      runtimeExecutable = "node",
      args = { "--inspect", "${file}" },
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
    {
      name = "Jest (Node2 with ts-node)",
      type = "node2",
      request = "launch",
      cwd = vim.loop.cwd(),
      runtimeArgs = { "--inspect-brk", "${workspaceFolder}/node_modules/.bin/jest" },
      runtimeExecutable = "node",
      args = { "${file}", "--runInBand", "--coverage", "false" },
      sourceMaps = true,
      port = 9229,
      skipFiles = { "<node_internals>/**", "node_modules/**" },
    },
  }
end
