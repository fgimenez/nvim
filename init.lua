-- init.lua
-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.wrap = false
vim.opt.breakindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Set leader key to space
vim.g.mapleader = " "

-- Plugin specifications
require("lazy").setup({
  -- LSP Support
  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v3.x',
    dependencies = {
      'neovim/nvim-lspconfig',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/nvim-cmp',
      'L3MON4D3/LuaSnip',
    }
  },
  
  -- Rust Tools
  {
    'simrat39/rust-tools.nvim',
    dependencies = {
      'neovim/nvim-lspconfig',
    },
  },
  
  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  },
  
  -- Syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
  },
  
  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim'
    }
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      -- Configure the colorscheme here
      require("tokyonight").setup({
        style = "storm", -- Options: storm, night, moon, day
        transparent = false,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          functions = {},
          variables = {},
        },
        -- Enhance Rust syntax highlighting specifically
        on_colors = function(colors)
          -- You can customize colors here if needed
        end,
        on_highlights = function(highlights, colors)
          -- Rust-specific highlighting
          highlights.RustAttribute = { fg = colors.purple }
          highlights.RustDerive = { fg = colors.purple }
          highlights.RustMacro = { fg = colors.blue1 }
          highlights.RustCommentLineDoc = { fg = colors.green }
          highlights.RustLifetime = { fg = colors.orange, italic = true }
        end
      })
      -- Set the colorscheme
      vim.cmd[[colorscheme tokyonight]]
    end
  },
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  {
    'ray-x/go.nvim',
    dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
    },
    config = function()
        require('go').setup()
    end,
    ft = {'go', 'gomod'},
    build = ':lua require("go.install").update_all_sync()',
  },
})

-- LSP Configuration
local lsp = require('lsp-zero').preset({})

-- Configure gopls (Go Language Server)
lspconfig = require('lspconfig')
lspconfig.gopls.setup {
  on_attach = lsp.on_attach,
  capabilities = lsp.get_capabilities(),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

-- Add Go-specific autocmd for formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Add some Go-specific keymaps if you want
-- Example: add test coverage
vim.keymap.set('n', '<leader>gt', '<cmd>!go test -v ./...<CR>', { desc = "Run Go tests" })
vim.keymap.set('n', '<leader>gc', '<cmd>!go test -cover ./...<CR>', { desc = "Run Go tests with coverage" })

lsp.on_attach(function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Key mappings
  local opts = {buffer = bufnr}
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {desc = "Show diagnostic error"})
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, {desc = "Previous diagnostic"})
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, {desc = "Next diagnostic"})
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {desc = "List all diagnostics"})
  vim.keymap.set('i', '<C-e>', '<End>', {desc = "Move to end of line"})
end)

-- Configure rust-tools
local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
    settings = {
      -- rust-analyzer settings
      ['rust-analyzer'] = {
        checkOnSave = {
          command = "clippy"
        },
        cargo = {
          allFeatures = true,
        },
        procMacro = {
          enable = true
        },
        rustfmt = {
          enable = true,
          rangeFormatting = {
            enable = true
          },
        },
      }
    }
  },
})

-- Custom command for vertical split with predefined width
vim.api.nvim_create_user_command('Vsp', function()
  vim.cmd('vsp')
  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.45))
end, {})
vim.keymap.set('n', '<Leader>vs', ':Vsp<CR>', { silent = true })

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
  ensure_installed = { "rust", "lua", "toml", "go" },
  auto_install = true,
  highlight = {
    enable = true,
  },
})

-- Telescope key mappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

-- Neo-tree setup
vim.keymap.set('n', '<leader>nt', ':Neotree toggle<CR>')

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.rs",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

local cmp = require('cmp')
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    -- Change Enter behavior to select instead of adding newline
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'luasnip' },
  },
})

-- Neo-tree configuration to show hidden files
require("neo-tree").setup({
  filesystem = {
    filtered_items = {
      visible = true,      -- This makes hidden files visible by default
      hide_dotfiles = false,
      hide_gitignored = false,
    },
  },
})
