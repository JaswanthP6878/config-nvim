return {

 -- gruvbox colorscheme
      {
        "morhetz/gruvbox",
        name = "gruvbox",
        priority = 1000, -- load before other UI plugins
        config = function()
          vim.o.background = "dark"
          vim.g.gruvbox_contrast_dark = "medium"
          vim.g.gruvbox_italic = 1
          vim.g.gruvbox_bold = 1
          vim.g.gruvbox_terminal_colors = 1
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
      ensure_installed = { "pyright", "gopls", "jdtls" },
      handlers = {
        -- Prevent mason-lspconfig from auto-configuring jdtls.
        -- nvim-jdtls handles jdtls exclusively via ftplugin/java.lua.
        jdtls = function() end,
      },
    },
  },

  -- LSP UI (peek/hover panes)
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("lspsaga").setup({
        ui = { border = "rounded" },
        lightbulb = { enable = false },
        symbol_in_winbar = { enable = false },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
        -- local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local border = "rounded"

        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
          border = border,
          max_width = 90,
          max_height = 25,
        })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
          border = border,
          max_width = 90,
          max_height = 12,
        })

        vim.diagnostic.config({
          float = {
            border = border,
            source = "if_many",
            max_width = 90,
          },
        })

        vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition", silent = true })
        vim.keymap.set("n", "gy", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek type definition", silent = true })
        vim.keymap.set("n", "gD", vim.lsp.buf.definition, { desc = "Go to definition", silent = true })
        vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Hover documentation", silent = true })
        vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, { desc = "Signature help", silent = true })
        vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature help", silent = true })
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol", silent = true })
        vim.keymap.set("n", "<leader>d", function()
          vim.diagnostic.open_float(nil, { border = border, source = "if_many", max_width = 90 })
        end, { desc = "Line diagnostics", silent = true })

        vim.lsp.config("pyright", {
          capabilities = capabilities,
          before_init = function(init_params, config)
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}

            local function executable(path)
              return path and path ~= "" and vim.fn.executable(path) == 1
            end

            local function project_python(root_dir)
              if not root_dir or root_dir == "" then
                return nil
              end

              local candidates = {
                root_dir .. "/.venv/bin/python",
                root_dir .. "/venv/bin/python",
              }

              for _, path in ipairs(candidates) do
                if executable(path) then
                  return path
                end
              end
            end

            local python_path
            local conda = vim.env.CONDA_PREFIX
            if conda and conda ~= "" then
              local conda_python = conda .. "/bin/python"
              if executable(conda_python) then
                python_path = conda_python
              end
            end

            if not python_path then
              local root_dir
              if init_params and init_params.rootUri then
                root_dir = vim.uri_to_fname(init_params.rootUri)
              elseif init_params and init_params.rootPath then
                root_dir = init_params.rootPath
              elseif type(config.root_dir) == "string" then
                root_dir = config.root_dir
              end
              python_path = project_python(root_dir)
            end

            if not python_path then
              local python3 = vim.fn.exepath("python3")
              if python3 ~= "" then
                python_path = python3
              end
            end

            if python_path then
              config.settings.python.pythonPath = python_path
            end
          end,
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "off",
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

  -- Java LSP (nvim-jdtls)
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "python", "go", "lua", "java" },
      highlight = { enable = true },
    },
  },

  -- Telescope (file finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules/",
            ".git/",
            "dist/",
            "build/",
            "target/",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>f.", function()
        builtin.find_files({
          cwd = vim.fn.expand("%:p:h"),
        })
      end, { desc = "Find files near current buffer" })
      vim.keymap.set("n", "<leader><leader>", builtin.oldfiles, { desc = "Recent files" })
      vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume picker" })
      vim.keymap.set("n", "<leader>fc", builtin.current_buffer_fuzzy_find, { desc = "Fuzzy find in current buffer" })
      vim.keymap.set("n", "<leader>fp", builtin.git_files, { desc = "Find git files" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "gr", builtin.lsp_references, { desc = "LSP references" })
      vim.keymap.set("n", "gi", builtin.lsp_implementations, { desc = "LSP implementations" })
      vim.keymap.set("n", "<leader>ds", builtin.lsp_document_symbols, { desc = "Document symbols" })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
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
