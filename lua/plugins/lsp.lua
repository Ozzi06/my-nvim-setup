return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Mason for managing external binaries
            { 'williamboman/mason.nvim', opts = {} },
            'WhoIsSethDaniel/mason-tool-installer.nvim',

            -- Visual feedback for LSP processing
            { 'j-hui/fidget.nvim', opts = {} },

            -- High-performance completion engine
            'saghen/blink.cmp',
        },
        config = function()
            -- 1. LSP Keymaps (Runs when an LSP connects to a file)
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('2vim-lsp-attach', { clear = true }),
                callback = function(event)
                    local map = function(keys, func, desc)
                        vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                    end

                    map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
                    map('gr', vim.lsp.buf.references, '[G]oto [R]eferences')
                    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('gra', vim.lsp.buf.code_action, '[C]ode [A]ction')
                    map('K', vim.lsp.buf.hover, 'Hover Documentation')
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                end,
            })

            -- 2. Setup Blink.cmp Capabilities
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            -- 3. Define the servers you want to use
            -- The KEYS here are the LSP names (used by nvim)
            local servers = {
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = 'Replace' },
                            workspace = {
                                checkThirdParty = false, -- THE FIX: Stop asking/scanning for non-nvim libs
                                -- Only index the runtime and your config.
                                -- Lazydev will inject plugin paths dynamically when you open them.
                                library = {
                                    vim.env.VIMRUNTIME,
                                },
                            },
                            -- lazydev handles the rest of the workspace settings automatically
                        },
                    },
                },
                pyright = {},
                -- ts_ls = {}, -- Uncomment if you use TypeScript
            }

            -- 4. Install the servers via Mason
            -- The NAMES here must match the Mason Registry names
            require('mason-tool-installer').setup({
                ensure_installed = {
                    'lua-language-server', -- Mapped to lua_ls
                    'pyright', -- Mapped to pyright
                    'stylua', -- Formatter for Lua
                },
            })

            -- 5. Native 0.11 LSP Activation Loop
            for name, config in pairs(servers) do
                -- Apply Blink capabilities to each server config
                config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})

                -- Native 0.11: Register the configuration
                vim.lsp.config(name, config)

                -- Native 0.11: Enable the server
                vim.lsp.enable(name)
            end
        end,
    },

    -- 6. Blink.cmp Configuration
    {
        'saghen/blink.cmp',
        version = '*', -- Download pre-built binaries
        opts = {
            keymap = { preset = 'default' },
            fuzzy = { implementation = 'lua' },
            appearance = {
                use_nvim_cmp_as_default = true,
                nerd_font_variant = 'mono',
            },
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },
        },
    },
}
