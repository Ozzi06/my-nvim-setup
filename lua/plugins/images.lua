return {
    '3rd/image.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
        backend = 'kitty',
        processor = 'magick_cli', -- requires ImageMagick installed
    },
    config = function(_, opts)
        require('image').setup(opts)

        -- Auto-open image files in a buffer
        vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
            pattern = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp' },
            callback = function()
                vim.opt_local.binary = true
                vim.opt_local.swapfile = false
                vim.opt_local.buflisted = false
                vim.opt_local.modifiable = false
                vim.opt_local.filetype = 'image'
            end,
        })
    end,
}
