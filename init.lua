-- Set leader key (must happen before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

-- Load core settings
require("config.options")
require("config.keymaps")

-- Bootstrap lazy.nvim (the plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim and tell it to look in the 'lua/plugins' folder
require("lazy").setup({
  spec = {
    { import = "plugins" }, -- This magic line loads everything in lua/plugins/
  },
})
