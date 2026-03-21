-- lua/config/python_scripts.lua
local M = {}

local function get_script_venv_dir(filepath)
    -- Hash the file path so every script gets a unique, predictable folder
    local hash = vim.fn.sha256(filepath):sub(1, 8)
    return '/tmp/nvim_py_scripts/' .. hash
end

local function sync_script_venv(bufnr, callback)
    local filepath = vim.api.nvim_buf_get_name(bufnr)
    local venv_dir = get_script_venv_dir(filepath)
    local python_path = venv_dir .. '/bin/python'

    vim.fn.mkdir(venv_dir, 'p')
    print('Syncing script dependencies via uv...')

    -- 1. Create venv
    vim.system({ 'uv', 'venv', venv_dir }, { text = true }):wait()

    -- 2. Install dependencies listed in the script block
    vim.system({
        'uv',
        'pip',
        'install',
        '-r',
        filepath,
        '--python',
        python_path,
    }, { text = true }, function(obj)
        vim.schedule(function()
            if obj.code == 0 then
                print('LSP venv synced: ' .. venv_dir)
                if callback then
                    callback()
                end
            else
                print('Error syncing venv: ' .. (obj.stderr or 'Unknown error'))
            end
        end)
    end)
end

function M.setup()
    -- Hook into the LSP attach event globally
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('PyrightScriptVenv', { clear = true }),
        callback = function(args)
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            local bufnr = args.buf

            -- Only care about Pyright (or basedpyright)
            if not client or (client.name ~= 'pyright' and client.name ~= 'basedpyright') then
                return
            end

            local filepath = vim.api.nvim_buf_get_name(bufnr)

            -- Check the first 30 lines for the PEP 723 block
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 30, false)
            local is_script_block = false
            for _, line in ipairs(lines) do
                if line:match('^# /// script') then
                    is_script_block = true
                    break
                end
            end

            if not is_script_block then
                return
            end

            local venv_dir = get_script_venv_dir(filepath)
            local python_exe = venv_dir .. '/bin/python'

            -- Function to tell Pyright to switch to the tmp venv
            local function update_lsp_path()
                client.config.settings = client.config.settings or {}
                client.config.settings.python = client.config.settings.python or {}
                client.config.settings.python.pythonPath = python_exe
                client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
            end

            -- Automatically sync if venv is missing
            if vim.fn.executable(python_exe) ~= 1 then
                sync_script_venv(bufnr, update_lsp_path)
            else
                -- Venv exists, just update LSP path
                update_lsp_path()
            end

            -- Add the :PySync command to manually update if you change dependencies
            vim.api.nvim_buf_create_user_command(bufnr, 'PySync', function()
                sync_script_venv(bufnr, update_lsp_path)
            end, { desc = 'Update script block venv' })
        end,
    })
end

return M
