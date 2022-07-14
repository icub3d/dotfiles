return function()
  local dap = require('dap')
  local dapui = require('dapui')
  dapui.setup()

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
  nnoremap('<leader>di', function() dap.step_in() end)
  nnoremap('<leader>dn', function() dap.step_over() end)
  nnoremap('<Up>', function() dap.step_out() end)
  nnoremap('<Down>', function() dap.step_in() end)
  nnoremap('<Right>', function() dap.step_over() end)

  dap.adapters.go = function(callback, config)
    local stdout = vim.loop.new_pipe(false)
    local handle
    local pid_or_err
    local port = 38697
    local opts = {
      stdio = { nil, stdout },
      args = { "dap", "-l", "127.0.0.1:" .. port },
      detached = true
    }
    handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
      stdout:close()
      handle:close()
      if code ~= 0 then
        print('dlv exited with code', code)
      end
    end)
    assert(handle, 'Error running dlv: ' .. tostring(pid_or_err))
    stdout:read_start(function(err, chunk)
      assert(not err, err)
      if chunk then
        vim.schedule(function()
          require('dap.repl').append(chunk)
        end)
      end
    end)
    -- Wait for delve to start
    vim.defer_fn(
      function()
        callback({ type = "server", host = "127.0.0.1", port = port })
      end,
      100)
  end
  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.configurations.go = {
    {
      type = "go",
      name = "Debug",
      request = "launch",
      program = "${file}"
    },
    {
      type = "go",
      name = "Debug test", -- configuration for debugging test files
      request = "launch",
      mode = "test",
      program = "${file}"
    },
    -- works with go.mod packages and sub packages
    {
      type = "go",
      name = "Debug test (go.mod)",
      request = "launch",
      mode = "test",
      program = "./${relativeFileDirname}"
    }
  }
end
