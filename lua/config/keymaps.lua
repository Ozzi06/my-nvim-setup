local keymap = vim.keymap
local diagnostic = vim.diagnostic
local api = vim.api
local hl = vim.hl



--
-- keymap.set('n', '<leader>ld', '<cmd>source %<CR>')
keymap.set('n', '<leader>ld', ':source %<CR>')

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
keymap.set('n', '<Esc>', ':nohlsearch<CR>')

keymap.set('n', '<leader>cn', ':cnext<CR>')
keymap.set('n', '<leader>cp', ':cprev<CR>')

-- Diagnostic keymaps
keymap.set('n', '<leader>q', diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Diagnostic keymaps
keymap.set('n', '<leader>q', diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

--  See `:help wincmd` for a list of all window commands
keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' }) keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })


-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`
api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    hl.on_yank()
  end,
})


-- [[ Diagnostic Configuration ]]
-- Show diagnostic signs in the sign column (gutter)
diagnostic.config {
  signs = true,
  underline = true,
  virtual_text = true, -- This disables the text that appears at the end of the line
  update_in_insert = true,
}
