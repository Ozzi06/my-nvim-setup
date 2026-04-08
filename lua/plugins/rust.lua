-- Example using lazy.nvim
return {
    {
        'mrcjkb/rustaceanvim',
        version = '^4', -- Recommended
        ft = { 'rust' },
        config = function()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(client, bufnr)
                        -- You can add keymaps here (e.g., Go to Definition, Hover)
                        -- Tip: Rust has great documentation.
                        -- K (standard LSP hover) will show you docs for any type.
                    end,
                    default_settings = {
                        ['rust-analyzer'] = {
                            checkOnSave = {
                                command = 'clippy', -- Use clippy instead of check for real-time linting
                            },
                        },
                    },
                },
            }
        end,
    },
}
