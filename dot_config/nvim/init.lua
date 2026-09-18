vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.mouse = "a"
vim.opt.confirm = true
vim.opt.visualbell = true
vim.opt.wildmode = "longest:full,full"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

vim.diagnostic.config({
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local output = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("Could not clone lazy.nvim:\n" .. output)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      opts = { style = "night" },
      config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight")
      end,
    },
    { "tpope/vim-fugitive", cmd = { "Git", "G" } },
    { "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } },
    {
      "nvim-lualine/lualine.nvim",
      event = "VeryLazy",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      opts = {
        options = {
          theme = "tokyonight",
          globalstatus = true,
        },
      },
    },
    {
      "mfussenegger/nvim-lint",
      event = { "BufReadPost", "BufWritePost", "BufNewFile" },
      config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
          yaml = { "yamllint" },
          ["yaml.ghaction"] = { "yamllint" },
        }

        vim.api.nvim_create_autocmd("BufWritePost", {
          callback = function()
            lint.try_lint()
          end,
        })
      end,
    },
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true, notify = false },
})
