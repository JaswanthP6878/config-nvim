return {

 -- gruvbox colorscheme
      {
        "morhetz/gruvbox",
        name = "gruvbox",
        priority = 1000, -- load before other UI plugins
        config = function()
          vim.o.background = "dark" -- or "light"
          vim.cmd.colorscheme("gruvbox")
        end,
      },
    -- Colorscheme (dark hacker vibe)
  -- Mason
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "pyright", "gopls" },
    },
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
        -- local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        vim.lsp.config("pyright", {
        settings = {
            capabilities = capabilities,
            python = {
              analysis = {
                typeCheckingMode = "off", -- instead of strict
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        })
	
      vim.lsp.enable("pyright")
      vim.lsp.enable("gopls")
    end,
  },

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
      },
        mapping = cmp.mapping.preset.insert({
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
            ["<Tab>"] = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "python", "go", "lua" },
      highlight = { enable = true },
    },
  },

  -- Telescope (file finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() 
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files)
        vim.keymap.set("n", "<leader>fg", builtin.live_grep)
        vim.keymap.set("n", "<leader>fb", builtin.buffers)
        vim.keymap.set("n", "<leader>f.", function()
          require("telescope.builtin").find_files({
            cwd = vim.fn.expand("%:p:h"),
          })
    end)
    vim.keymap.set("n", "gd", builtin.lsp_definitions)
    vim.keymap.set("n", "gr", builtin.lsp_references)
    vim.keymap.set("n", "gi", builtin.lsp_implementations)
    vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols)
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function(nvim --version | grep clipboard
)
      require("gitsigns").setup()
    end,
  },
    {
      "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup({})
      end,
    },

}
