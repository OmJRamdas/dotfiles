-- options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- keymaps
vim.g.mapleader = " "

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
})

-- mason
require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "pyright" } })

-- lsp
vim.lsp.config("lua_ls", {})
vim.lsp.enable("lua_ls")

-- telescope keymaps
local t = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", t.find_files)
vim.keymap.set("n", "<leader>fg", t.live_grep)
vim.keymap.set("n", "<leader>fb", t.buffers)

-- modules
-- require("config.keymaps")
-- require("config.autocmds")
