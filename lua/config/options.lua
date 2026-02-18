local opt = vim.opt

opt.tabstop = 4 -- A tab character counts for 4 spaces
opt.shiftwidth = 4 -- Indentation uses 4 spaces when auto-indenting
opt.expandtab = true -- Convert tabs to spaces

opt.number = true
opt.relativenumber = false

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = 'a'
opt.showmode = false

opt.clipboard = 'unnamedplus'

-- Make line wrap match indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

opt.signcolumn = 'yes'

-- Decrease update time to make some stuff trigger faster
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true -- makes whitespaces visible
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
opt.inccommand = 'split'

-- Show which line your cursor is on
opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 15
