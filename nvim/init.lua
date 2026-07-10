-- options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.showmode = false -- lualine already shows the mode

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
    -- config style borrowed from LazyVim's lualine spec (lua/lazyvim/plugins/ui.lua),
    -- adapted since we don't have LazyVim's icons/root_dir/Snacks/noice/dap helpers
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- explicit theme instead of "auto": with no colorscheme installed, "auto"
      -- gives every mode the same dull grey, so the section-a box/arrow has no
      -- contrast against section b in normal mode. Fixed colors per mode, with
      -- b/c held constant, keep the same box shape in every mode.
      local bg = "#1a1b26"
      local bg2 = "#24283b"
      local fg = "#c0caf5"
      local function mode_hl(color)
        return {
          a = { bg = color, fg = bg, gui = "bold" },
          b = { bg = bg2, fg = fg },
          c = { bg = bg, fg = fg },
        }
      end
      local lualine_theme = {
        normal = mode_hl("#3b82f6"), -- blue
        insert = mode_hl("#f97316"), -- orange
        visual = mode_hl("#a855f7"), -- purple
        replace = mode_hl("#ef4444"), -- red
        command = mode_hl("#eab308"), -- yellow
        terminal = mode_hl("#10b981"), -- green
        inactive = {
          a = { bg = bg, fg = "#565f89" },
          b = { bg = bg, fg = "#565f89" },
          c = { bg = bg, fg = "#565f89" },
        },
      }

      require("lualine").setup({
        options = {
          theme = lualine_theme,
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              -- pad every mode name to the same width so sections to the
              -- right don't shift when switching NORMAL/INSERT/VISUAL/etc.
              "mode",
              fmt = function(str) return string.format("%-8s", str) end,
            },
          },
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
          },
          lualine_c = {
            -- current working directory (LazyVim calls this "root_dir")
            { function() return vim.fn.fnamemodify(vim.fn.getcwd(), ":~") end, icon = "" },
            {
              "diagnostics",
              symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1 },
          },
          lualine_x = {
            {
              "diff",
              symbols = { added = "+", modified = "~", removed = "-" },
              source = function()
                local gitsigns = vim.b.gitsigns_status_dict
                if gitsigns then
                  return { added = gitsigns.added, modified = gitsigns.changed, removed = gitsigns.removed }
                end
              end,
            },
          },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function() return " " .. os.date("%R") end,
          },
        },
        extensions = { "nvim-tree", "lazy" },
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
