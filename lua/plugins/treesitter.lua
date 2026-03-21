return {
    'nvim-treesitter/nvim-treesitter',
    -- Branch is 'main' by default now. No need for version = 'v0.9.3' if you want the latest.
    build = ':TSUpdate',
    config = function()
        local ts = require('nvim-treesitter')

        -- 1. Initialize the plugin (optional if using defaults)
        ts.setup()

        -- 2. "ensure_installed" replacement
        -- We manually check if parsers are missing and install them
        local ensure_installed = {
            'bash',
            'c',
            'diff',
            'html',
            'lua',
            'luadoc',
            'markdown',
            'markdown_inline',
            'query',
            'vim',
            'vimdoc',
        }

        local to_install = {}
        for _, lang in ipairs(ensure_installed) do
            -- Check if the parser file already exists in Neovim's path
            if #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0 then
                table.insert(to_install, lang)
            end
        end

        if #to_install > 0 then
            ts.install(to_install)
        end

        -- 3. "highlight = { enable = true }" replacement
        -- We use an autocommand to start highlighting whenever a supported file is opened
        vim.api.nvim_create_autocmd('FileType', {
            desc = 'Enable Treesitter Highlighting',
            callback = function(args)
                local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                if lang then
                    pcall(vim.treesitter.start, args.buf, lang)
                end
            end,
        })

        -- 4. Enable Indentation (optional)
        -- Uses the new indentation expression provided by the plugin
        vim.api.nvim_create_autocmd('FileType', {
            callback = function()
                vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
