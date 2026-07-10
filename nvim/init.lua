-- options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true

-- transparent background: let the terminal's background/theme (e.g. WezTerm) show through
local function set_transparent_bg()
  for _, group in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" }) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end
end
set_transparent_bg()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_transparent_bg })

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
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            "branch",
            {
              -- repo name (git toplevel dir), e.g. "tetramem-work"
              function()
                local dict = vim.b.gitsigns_status_dict
                if dict and dict.root then
                  return vim.fn.fnamemodify(dict.root, ":t")
                end
                return ""
              end,
              icon = "",
            },
            "diff",
            "diagnostics",
          },
          lualine_c = {
            -- current working directory
            { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end, icon = "" },
            { "filename", path = 1 },
          },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },
})

-- mason + lsp (requires nvim 0.10+)
if vim.fn.has("nvim-0.10") == 1 then
  require("mason").setup()
  require("mason-lspconfig").setup({ ensure_installed = { "lua_ls", "pyright", "clangd" } })
  vim.lsp.enable({ "lua_ls", "pyright", "clangd" })
end

-- lsp keymaps (buffer-local, only set where an LSP client is attached)
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
    vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, opts)
  end,
})

-- treesitter highlighting (main branch API: install parsers, then enable
-- highlighting per filetype via core vim.treesitter.start())
local ts_filetypes = { "markdown", "lua", "python", "bash", "c", "cpp", "rust" }
require("nvim-treesitter").install({ "markdown_inline", unpack(ts_filetypes) })
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    local ok, loaded = pcall(vim.treesitter.language.add, lang)
    if ok and loaded then
      vim.treesitter.start()
    end
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

-- gitsigns keymaps
vim.keymap.set("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end)
vim.keymap.set("n", "<leader>tb", function() require("gitsigns").toggle_current_line_blame() end)

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
