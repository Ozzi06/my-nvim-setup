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
                    map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                    map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })
                    -- WARN: This is not Goto Definition, this is Goto Declaration.
                    --  For example, in C this would take you to the header.
                    map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

                    -- The following two autocommands are used to highlight references of the
                    -- word under your cursor when your cursor rests there for a little while.
                    --    See `:help CursorHold` for information about when this is executed
                    --
                    -- When you move your cursor, the highlights will be cleared (the second autocommand).
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
                        local highlight_augroup =
                            vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
                        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.document_highlight,
                        })

                        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
                            buffer = event.buf,
                            group = highlight_augroup,
                            callback = vim.lsp.buf.clear_references,
                        })

                        vim.api.nvim_create_autocmd('LspDetach', {
                            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                            callback = function(event2)
                                vim.lsp.buf.clear_references()
                                vim.api.nvim_clear_autocmds({ group = 'kickstart-lsp-highlight', buffer = event2.buf })
                            end,
                        })
                    end
                end,
            })

            -- 2. Setup Blink.cmp Capabilities
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            -- 3. Define the servers you want to use
            -- The KEYS here are the LSP names (used by nvim)
            local servers = {
                clangd = {},
                basedpyright = {
                    settings = {
                        basedpyright = {
                            analysis = {
                                typeCheckingMode = 'standard', -- instead of "all", reduces noise
                                reportAny = false, -- kills all the "Type Any is not allowed" warnings
                                reportUnknownVariableType = true,
                                reportUnknownMemberType = true,
                                reportUnknownArgumentType = true,
                                reportMissingTypeStubs = true, -- kills the laspy stub warning
                            },
                        },
                    },
                },
                ruff = {
                    capabilities = {
                        offsetEncoding = { 'utf-16' },
                    },
                },
                lua_ls = {
                    settings = {
                        Lua = {
                            completion = { callSnippet = 'Replace' },
                            workspace = {
                                checkThirdParty = false,
                                library = {
                                    vim.env.VIMRUNTIME,
                                },
                            },
                        },
                    },
                },
                ts_ls = {},
            }

            -- 4. Install the servers via Mason
            -- The NAMES here must match the Mason Registry names
            require('mason-tool-installer').setup({
                ensure_installed = {
                    'lua-language-server', -- Mapped to lua_ls
                    'basedpyright',
                    'stylua', -- Formatter for Lua
                    'ruff',
                    'ruff-lsp',
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
