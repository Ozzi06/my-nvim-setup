return { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    config = function()
        local filetypes = {
            'bash',
            'c',
            'cpp',
            'css',
            'diff',
            'go',
            'html',
            'javascript',
            'json',
            'lua',
            'luadoc',
            'markdown',
            'markdown_inline',
            'python',
            'query',
            'rust',
            'toml',
            'typescript',
            'vim',
            'vimdoc',
            'yaml',
        }
        require('nvim-treesitter').install(filetypes)
        vim.api.nvim_create_autocmd('FileType', {
            pattern = filetypes,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
