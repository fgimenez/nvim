-- init.lua
-- Install package manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
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
vim.opt.wrap = true
vim.opt.showbreak = "↪ "

-- Set leader key to space
vim.g.mapleader = " "

-- Plugin specifications
require("lazy").setup({
  -- LSP Support
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
    },
  },

  -- Formatting (prettier for JS/TS and friends, LSP as fallback)
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    cmd = { 'ConformInfo' },
  },

  -- Autocompletion
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  -- Snippets
  {
    'L3MON4D3/LuaSnip',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
  },

  -- Rust Tools - Modern replacement for rust-tools.nvim
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    lazy = false,
    ft = { 'rust' },
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
    branch = 'master',
    lazy = false,
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
  {
    'ray-x/go.nvim',
    dependencies = {
        'ray-x/guihua.lua',
        'neovim/nvim-lspconfig',
    },
    config = function()
        require('go').setup({
          -- codelens in current go.nvim needs nvim 0.12+ (vim.lsp.codelens.enable)
          lsp_codelens = false,
        })
    end,
    ft = {'go', 'gomod'},
    build = ':lua require("go.install").update_all_sync()',
  },
  {
    'numToStr/Comment.nvim',
    opts = {},
    lazy = false,
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = {
      'nvim-lua/plenary.nvim',
    }
  },
  {
    'j-hui/fidget.nvim',
    tag = 'legacy',
    config = function()
        require('fidget').setup()
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    event = "BufReadPre",
    config = function()
      require('gitsigns').setup({
        -- Simple defaults - just show signs
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
      })
    end
  },
  {
    "greggh/claude-code.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim", -- Required for git operations
    },
    config = function()
        require("claude-code").setup()
    end
  },
})

-- LSP Configuration

-- Global mappings
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end)
vim.keymap.set('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      require('conform').format({ async = true, lsp_format = 'fallback' })
    end, opts)
    vim.keymap.set('i', '<C-e>', '<End>', opts)
  end,
})

-- Set up lspconfig with completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure individual language servers using new vim.lsp.config API
-- Go Language Server
vim.lsp.config.gopls = {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  capabilities = capabilities,
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
vim.lsp.enable('gopls')

-- Rustaceanvim configuration
-- This plugin automatically configures rust-analyzer, but we can customize it via g:rustaceanvim
vim.g.rustaceanvim = {
  server = {
    capabilities = capabilities,
    default_settings = {
      ['rust-analyzer'] = {
        checkOnSave = true,
        check = {
          command = "clippy",
          allFeatures = true,
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
}

-- TypeScript / JavaScript Language Server
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'javascript', 'javascriptreact', 'javascript.jsx',
    'typescript', 'typescriptreact', 'typescript.tsx',
  },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
  capabilities = capabilities,
  init_options = {
    hostInfo = 'neovim',
    preferences = {
      includeInlayParameterNameHints = 'literals',
      includeInlayFunctionParameterTypeHints = true,
      includeInlayVariableTypeHints = false,
      includeInlayPropertyDeclarationTypeHints = true,
      includeInlayFunctionLikeReturnTypeHints = true,
    },
  },
}
vim.lsp.enable('ts_ls')

-- ESLint Language Server (needs vscode-langservers-extracted; attaches only when
-- an eslint config file is found in the project). Use :LspEslintFixAll to apply fixes.
vim.lsp.config('eslint', {
  capabilities = capabilities,
})
vim.lsp.enable('eslint')

-- Lua Language Server
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
}
vim.lsp.enable('lua_ls')

-- Format on save for specific filetypes
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.rs", "*.go" },
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Formatting with conform.nvim
-- Prefers the project's node_modules/.bin/prettier, falls back to the global one.
local conform_formatters_by_ft = {
  javascript = { 'prettier' },
  javascriptreact = { 'prettier' },
  typescript = { 'prettier' },
  typescriptreact = { 'prettier' },
  json = { 'prettier' },
  jsonc = { 'prettier' },
  css = { 'prettier' },
  html = { 'prettier' },
  yaml = { 'prettier' },
  markdown = { 'prettier' },
}

require('conform').setup({
  formatters_by_ft = conform_formatters_by_ft,
  format_on_save = function(bufnr)
    -- Only format filetypes listed above; other filetypes keep their own handling
    if not conform_formatters_by_ft[vim.bo[bufnr].filetype] then
      return
    end
    return { timeout_ms = 3000, lsp_format = 'fallback' }
  end,
})

-- Completion setup
local cmp = require('cmp')
local luasnip = require('luasnip')

-- Load friendly snippets
require('luasnip.loaders.from_vscode').lazy_load()

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
})

-- Go-specific keymaps
vim.keymap.set('n', '<leader>gt', '<cmd>!go test -v ./...<CR>', { desc = "Run Go tests" })
vim.keymap.set('n', '<leader>gc', '<cmd>!go test -cover ./...<CR>', { desc = "Run Go tests with coverage" })

-- Custom command for vertical split with predefined width
vim.api.nvim_create_user_command('Vsp', function()
  vim.cmd('vsp')
  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.45))
end, {})
vim.keymap.set('n', '<Leader>vs', ':Vsp<CR>', { silent = true })

-- Treesitter configuration
require('nvim-treesitter.configs').setup({
  ensure_installed = { "rust", "lua", "toml", "go", "typescript", "tsx", "javascript", "json" },
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

-- Comment.nvim setup
require('Comment').setup({
  -- Use default mappings (gcc for line comment, gc for visual selection)
  -- gc{motion} for commenting by motion
})

-- Spectre
vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open()<CR>', {
  desc = "Open Spectre for search and replace"
})

-- Telescope search in directory, uses tab completion for paths
vim.keymap.set('n', '<leader>f/', function()
  local input = vim.fn.input({
    prompt = "Directory: ",
    default = vim.fn.getcwd() .. "/",
    completion = "dir"
  })

  if input ~= "" then
    builtin.find_files({
      cwd = input,
      prompt_title = "🔍 " .. vim.fn.fnamemodify(input, ":t")
    })
  end
end)

vim.keymap.set('n', '<leader>g/', function()
  local input = vim.fn.input({
    prompt = "Grep in: ",
    default = vim.fn.getcwd() .. "/",
    completion = "dir"
  })

  if input ~= "" then
    builtin.live_grep({
      cwd = input,
      prompt_title = "🔍 " .. vim.fn.fnamemodify(input, ":t")
    })
  end
end)

-- Automatically trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Save cursor position
    local save_cursor = vim.fn.getpos(".")
    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
    -- Restore cursor position
    vim.fn.setpos(".", save_cursor)
  end,
})
