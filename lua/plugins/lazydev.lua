return {
    {
        'folke/lazydev.nvim',
        ft = 'lua', -- only load on lua files
        opts = {
            library = {
                -- This line specifically fixes the 'fs_stat' and 'vim.uv' warnings
                { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
            },
        },
    },
}
