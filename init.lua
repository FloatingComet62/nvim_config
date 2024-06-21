vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  -- Git related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      'folke/neodev.nvim',

      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      { 'j-hui/fidget.nvim', opts = {} },
    },
  },

  {
    -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 then
            return
          end
          return 'make install_jsregexp'
        end)(),
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
    },
  },

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(buf)
        local gitsigns = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = buf
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(function()
            gitsigns.next_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(function()
            gitsigns.prev_hunk()
          end)
          return '<Ignore>'
        end, { expr = true, desc = 'Jump to previous hunk' })

        -- Actions
        -- visual mode
        map('v', '<leader>hs', function()
          gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'stage git hunk' })
        map('v', '<leader>hr', function()
          gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = 'reset git hunk' })
        -- normal mode
        map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'git stage hunk' })
        map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        map('n', '<leader>hu', gitsigns.undo_stage_hunk, { desc = 'undo stage hunk' })
        map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'preview git hunk' })
        map('n', '<leader>hb', function()
          gitsigns.blame_line { full = false }
        end, { desc = 'git blame line' })
        map('n', '<leader>hd', gitsigns.diffthis, { desc = 'git diff against index' })
        map('n', '<leader>hD', function()
          gitsigns.diffthis '~'
        end, { desc = 'git diff against last commit' })

        -- Toggles
        map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'toggle git blame line' })
        map('n', '<leader>td', gitsigns.toggle_deleted, { desc = 'toggle git show deleted' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    },
  },

  -- {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   lazy = false,
  --   config = function()
  --     require('onedark').setup {
  --       -- Set a style preset. 'dark' is default.
  --       style = 'dark', -- dark, darker, cool, deep, warm, warmer, light
  --     }
  --     require('onedark').load()
  --   end,
  -- },

  {
    'morhetz/gruvbox',
    config = function()
      vim.cmd.colorscheme("gruvbox")
    end
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  {
    -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {},
  },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy Finder (files, lsp, etc)
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
  },
}, {})

-- [[ Basic Configuration ]]
vim.o.hlsearch      = false
vim.wo.number       = true               -- Make line numbers default
vim.o.mouse         = 'a'                -- Enable mouse mode
vim.o.clipboard     = 'unnamedplus'      -- Sync clipboard between OS and Neovim.
vim.o.breakindent   = true               -- Enable break indent
vim.o.undofile      = true               -- Save undo history
vim.o.ignorecase    = true               -- Case-insensitive searching UNLESS \C or capital in search
vim.o.smartcase     = true
vim.wo.signcolumn   = 'yes'              -- Keep signcolumn on by default
vim.o.updatetime    = 250                -- Decrease update time
vim.o.timeoutlen    = 300
vim.o.completeopt   = 'menuone,noselect' -- Set completeopt to have a better completion experience
vim.o.termguicolors = true               -- NOTE: You should make sure your terminal supports this
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.wrap = false                     -- Word wrap
vim.opt.colorcolumn = "100"              -- Have a column marker to prevent WIIIIDDDDEEE code
vim.opt.number = true                    -- Line numbers
vim.opt.shell = "nu.exe"                 -- Changing the default terminal
vim.g.gui_font_face = "Jetbrains Mono"   -- Changing the default font
vim.opt.splitbelow = true                -- Default splitting right
vim.opt.splitright = true                -- Default splitting left
vim.g.gui_font_default_size = 12
vim.g.gui_font_size = vim.g.gui_font_default_size
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

-- [[ Basic Keymaps ]]
local nmap = function(keys, func, desc)
  vim.keymap.set('n', keys, func, { desc = desc })
end
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
nmap('[d', vim.diagnostic.goto_prev, 'Go to previous diagnostic message')
nmap(']d', vim.diagnostic.goto_next, 'Go to next diagnostic message')
nmap('<leader>e', vim.diagnostic.open_float, 'Open floating diagnostic message')
nmap( '<leader>q', vim.diagnostic.setloclist, 'Open diagnostics list')
vim.keymap.set('n', '<leader>y', ':bd<CR>', { noremap = true, silent = true, desc='Delete buffer' })

-- Replaced by Harpoon
-- vim.keymap.set('n', '<leader>n', ':bn<CR>', { noremap = true, silent = true, desc='Next buffer' })
-- vim.keymap.set('n', '<leader>p', ':bp<CR>', { noremap = true, silent = true, desc='Previous buffer' })

-- [[ Terminal ]]
nmap("<leader>tv", function() vim.cmd("vsplit | terminal") end, "Create a vertical terminal split")
nmap("<leader>th", function() vim.cmd("split | terminal") end, "Create a horizontal terminal split")
-- Escaping the terminal
vim.keymap.set("t", "<leader><esc>", "<C-\\><C-n>", { noremap = true })

-- [[ Naivgating between splits ]]
local nav_splits = function(key)
  vim.keymap.set(
    "n",
    "<leader>" .. key,
    "<C-w>" .. key,
    { noremap = true, silent = true, desc = "Move around splits" }
  );
end
for i = 0, 4 do
  nav_splits(("hjkl"):sub(i, i))
end

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- [[ Color Scheme ]]
nmap("<leader>tl", function() vim.o.background = "light" end, "Change the theme to light")
nmap("<leader>td", function() vim.o.background = "dark" end, "Change the theme to dark")

-- [[ Hide Window ]]
nmap("<leader>z", function() vim.cmd("hide") end, "Hide the buffer")

-- [[ Font size ]]
RefreshGuiFont = function()
  -- DreamBerd
  vim.opt.guifont = string.format("%s:h%s",vim.g.gui_font_face, vim.g.gui_font_size)
end

ResizeGuiFont = function(delta)
  vim.g.gui_font_size = vim.g.gui_font_size + delta
  RefreshGuiFont()
end

ResetGuiFont = function ()
  vim.g.gui_font_size = vim.g.gui_font_default_size
  RefreshGuiFont()
end

ResetGuiFont()

local opts = { noremap = true, silent = true }

vim.keymap.set("n", "<leader>+", function() ResizeGuiFont(1)  end, opts)
vim.keymap.set("n", "<leader>-", function() ResizeGuiFont(-1) end, opts)
vim.keymap.set("n", "<leader>=", function() ResetGuiFont() end, opts)

-- [[ Telescope ]]
local telescope = require 'telescope'
telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        -- ['<C-h>'] = require('telescope.actions').select_horizontal,
        -- use <C-x> dickhead, it's the convention
      },
    },
  },
}

-- Enable telescope fzf native, if installed
pcall(telescope.load_extension, 'fzf')

local function find_git_root()
  local current_file = vim.api.nvim_buf_get_name(0)
  local current_dir
  local cwd = vim.fn.getcwd()
  if current_file == '' then
    current_dir = cwd
  else
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  end

  local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
  if vim.v.shell_error ~= 0 then
    print 'Not a git repository. Searching on current working directory'
    return cwd
  end
  return git_root
end

local telescope_builtin = require 'telescope.builtin';

vim.api.nvim_create_user_command('LiveGrepGitRoot', function()
  local git_root = find_git_root()
  if git_root then
    telescope_builtin.live_grep {
      search_dirs = { git_root },
    }
  end
end, {})

nmap('<leader>?', telescope_builtin.oldfiles, '[?] Find recently opened files')
nmap('<leader><space>', telescope_builtin.buffers, '[ ] Find existing buffers')
nmap('<leader>/', function()
  telescope_builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, '[/] Fuzzily search in current buffer')

nmap('<leader>s/', function()
  telescope_builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, '[S]earch [/] in Open Files')
nmap('<leader>ss', telescope_builtin.builtin, '[S]earch [S]elect Telescope')
nmap('<leader>gf', telescope_builtin.git_files, 'Search [G]it [F]iles')
nmap('<leader>sf', telescope_builtin.find_files, '[S]earch [F]iles')
nmap('<leader>sh', telescope_builtin.help_tags, '[S]earch [H]elp')
nmap('<leader>sw', telescope_builtin.grep_string, '[S]earch current [W]ord')
nmap('<leader>sg', telescope_builtin.live_grep, '[S]earch by [G]rep')
nmap('<leader>sG', ':LiveGrepGitRoot<cr>', '[S]earch by [G]rep on Git Root')
nmap('<leader>sd', telescope_builtin.diagnostics, '[S]earch [D]iagnostics')
nmap('<leader>sr', telescope_builtin.resume, '[S]earch [R]esume')

-- [[ Treesitter ]]
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup {
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash' },
    auto_install = false,
    sync_install = false,
    ignore_install = {},
    modules = {},
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = {
          [']m'] = '@function.outer',
          [']]'] = '@class.outer',
        },
        goto_next_end = {
          [']M'] = '@function.outer',
          [']['] = '@class.outer',
        },
        goto_previous_start = {
          ['[m'] = '@function.outer',
          ['[['] = '@class.outer',
        },
        goto_previous_end = {
          ['[M'] = '@function.outer',
          ['[]'] = '@class.outer',
        },
      },
      swap = {
        enable = true,
      },
    },
  }
end, 0)

-- [[ LSP ]]
local on_attach = function(_, bufnr)
  local lsp_nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    nmap(keys, func, desc)
  end

  lsp_nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  lsp_nmap('<leader>ca', function()
    vim.lsp.buf.code_action { context = { only = { 'quickfix', 'refactor', 'source' } } }
  end, '[C]ode [A]ction')

  lsp_nmap('gd', telescope_builtin.lsp_definitions, '[G]oto [D]efinition')
  lsp_nmap('gr', telescope_builtin.lsp_references, '[G]oto [R]eferences')
  lsp_nmap('gI', telescope_builtin.lsp_implementations, '[G]oto [I]mplementation')
  lsp_nmap('<leader>D', telescope_builtin.lsp_type_definitions, 'Type [D]efinition')
  lsp_nmap('<leader>ds', telescope_builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
  lsp_nmap('<leader>ws', telescope_builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  lsp_nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  lsp_nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  lsp_nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  lsp_nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  lsp_nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  lsp_nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local which_key = require 'which-key'
which_key.register {
  ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
  ['<leader>d'] = { name = '[D]ocument', _ = 'which_key_ignore' },
  ['<leader>g'] = { name = '[G]it', _ = 'which_key_ignore' },
  ['<leader>h'] = { name = 'Git [H]unk', _ = 'which_key_ignore' },
  ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
  ['<leader>s'] = { name = '[S]earch', _ = 'which_key_ignore' },
  ['<leader>t'] = { name = '[T]oggle, [T]heme and [T]erminal', _ = 'which_key_ignore' },
  ['<leader>w'] = { name = '[W]orkspace', _ = 'which_key_ignore' },
  ['<leader>x'] = { name = 'Horizontal splitting', _ = 'which_key_ignore' },
  ['<leader>v'] = { name = '[V]ertical splitting', _ = 'which_key_ignore' },
}
which_key.register({
  ['<leader>'] = { name = 'VISUAL <leader>' },
  ['<leader>h'] = { 'Git [H]unk' },
}, { mode = 'v' })

require('mason').setup()
require('mason-lspconfig').setup()

local servers = {
  clangd = {
    filetypes = {"c", "cpp"}
  },
  -- gopls = {},
  -- pyright = {},
  rust_analyzer = {
    settings = {
      cargo = {
        allFeatures = true,
      }
    },
    filetypes = {"rust"},
  },
  zls = {
    filetypes = {"zig"}
  },
  cmake = {
    filetypes = {"txt"}
  },
  -- prettier = {
  --   filetypes = {"css", "html", "jsx", "js", "ts", "tsx", "md", "json", "vue", "yaml"}
  -- },
  tsserver = {
    filetypes = {"ts"}
  },
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

require('neodev').setup()

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}
mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ nvim-cmp ]]
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = {
    completeopt = 'menu,menuone,noinsert',
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
  },
}

-- [[ Harpoon ]]
local harpoon = require("harpoon")
harpoon:setup({})

nmap("<leader>a", function() harpoon:list():append() end, '[A]dd to the harpoon list')
nmap("<leader>s", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end, 'Open the [h]arpoon list')
nmap("<leader>hc", function() harpoon:list():clear() end, '[C]lear the harpoon list')

local harpoon_mapping = function(num)
  nmap(
    "<leader>" .. num,
    function()
      harpoon:list():select(num)
    end,
    'Go to Item[' .. num .. '] in the harpoon list')
end
local harpoon_mapping_horizontal = function(num)
  nmap(
    "<leader>x" .. num,
    function()
      vim.cmd("split")
      harpoon:list():select(num)
    end,
    'Open a horizontal split of Item[' .. num .. '] in the harpoon list')
end
local harpoon_mapping_vertical = function(num)
  nmap(
    "<leader>v" .. num,
    function()
      vim.cmd("vsplit")
      harpoon:list():select(num)
    end,
    'Open vertical split of Item[' .. num ..'] in the harpoon list')
end

for i = 1, 5, 1 do
  harpoon_mapping(i)
  harpoon_mapping_vertical(i)
  harpoon_mapping_horizontal(i)
end

-- Toggle previous & next buffers stored within Harpoon list
nmap("<leader>p", function() harpoon:list():prev() end, 'Go [p]revious in the harpoon list')
nmap("<leader>f", function() harpoon:list():next() end, 'Go [f]orward in the harpoon list')

-- Keymaps for opening in splits
-- https://github.com/ThePrimeagen/harpoon/pull/430/commits/c57cb1995153cd13cc62386d2bd66c84762f7d81
harpoon:extend({
  UI_CREATE = function(cx)
    vim.keymap.set("n", "<C-v>", function()
      harpoon.ui:select_menu_item({ vsplit = true })
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-x>", function()
      harpoon.ui:select_menu_item({ split = true })
    end, { buffer = cx.bufnr })

    vim.keymap.set("n", "<C-t>", function()
      harpoon.ui:select_menu_item({ tabedit = true })
    end, { buffer = cx.bufnr })
  end
})
