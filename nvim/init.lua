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
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
    config = function()
      require("neogit").setup()
    end,
  },
})

-- mason + lsp (requires nvim 0.10+)
if vim.fn.has("nvim-0.10") == 1 then
  require("mason").setup()
  require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "pyright" } })
  vim.lsp.enable({ "lua_ls", "pyright" })
end

-- treesitter highlighting (main branch API: install parsers, then enable
-- highlighting per filetype via core vim.treesitter.start())
local ts_filetypes = { "markdown", "lua", "python", "bash", "c", "cpp", "rust" }
require("nvim-treesitter").install({ "markdown_inline", unpack(ts_filetypes) })
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  callback = function()
    vim.treesitter.start()
  end,
})

-- telescope keymaps
if vim.fn.has("nvim-0.11") == 1 then
  local t = require("telescope.builtin")
  vim.keymap.set("n", "<leader>ff", t.find_files)
  vim.keymap.set("n", "<leader>fg", t.live_grep)
  vim.keymap.set("n", "<leader>fb", t.buffers)
end

-- nvim-tree keymaps
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")

-- neogit keymaps
vim.keymap.set("n", "<leader>g", "<cmd>Neogit<CR>")

-- markdown: wrap at word boundaries and indent wrapped lines under text
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
  end,
})

-- modules
-- require("config.keymaps")
-- require("config.autocmds")
