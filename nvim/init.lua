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
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, cond = vim.fn.has("nvim-0.11") == 1 },
  { "neovim/nvim-lspconfig", cond = vim.fn.has("nvim-0.10") == 1 },
  { "williamboman/mason.nvim", cond = vim.fn.has("nvim-0.10") == 1 },
  { "williamboman/mason-lspconfig.nvim", cond = vim.fn.has("nvim-0.10") == 1 },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
})

-- mason + lsp (requires nvim 0.10+)
if vim.fn.has("nvim-0.10") == 1 then
  require("mason").setup()
  require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "pyright" } })
  local lspconfig = require("lspconfig")
  lspconfig.lua_ls.setup({})
  lspconfig.pyright.setup({})
end

-- telescope keymaps
if vim.fn.has("nvim-0.11") == 1 then
  local t = require("telescope.builtin")
  vim.keymap.set("n", "<leader>ff", t.find_files)
  vim.keymap.set("n", "<leader>fg", t.live_grep)
  vim.keymap.set("n", "<leader>fb", t.buffers)
end

-- modules
-- require("config.keymaps")
-- require("config.autocmds")
