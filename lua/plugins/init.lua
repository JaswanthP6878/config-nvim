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
         if type(_G.apply_ghostty_harmonized_highlights) == "function" then
              _G.apply_ghostty_harmonized_highlights()
              end
          end,
        },

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
      ensure_installed = { "pyright", "gopls", "jdtls", "rust_analyzer", "clangd" },
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
      vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "Code action", silent = true })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    config = function()
        -- local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        local border = "rounded"

        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ff5555" })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",  { fg = "#f1fa8c" })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo",  { fg = "#8be9fd" })
        vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint",  { fg = "#50fa7b" })


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
          virtual_text = {
            prefix = "",        -- dot before the message
            spacing = 4,
            source = "if_many",  -- show source only when multiple LSPs
            severity = {
              min = vim.diagnostic.severity.HINT,
            },
          },
          signs = {
            severity = { min = vim.diagnostic.severity.HINT },
            text = {
              [vim.diagnostic.severity.ERROR] = "E",
              [vim.diagnostic.severity.WARN]  = "W",
              [vim.diagnostic.severity.INFO]  = "I",
              [vim.diagnostic.severity.HINT]  = "H",
            },
          },
          underline = true,
          severity_sort = true,
          float = {
            border = border,
            source = "if_many",
            max_width = 90,
          },
        })

        vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", { desc = "Peek definition", silent = true })
        vim.keymap.set("n", "gy", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "Peek type definition", silent = true })
        vim.keymap.set("n", "gD", vim.lsp.buf.definition, { desc = "Go to definition", silent = true })
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

      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            checkOnSave = true,
            check = {
              command = "check",
            },
            imports = {
              granularity = {
                group = "module",
              },
              prefix = "self",
            },
          },
        },
      })

      vim.lsp.config("clangd", {
        capabilities = capabilities,
        cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu" },
        filetypes = { "c", "cpp", "objc", "objcpp" },
        init_options = {
          clangdFileStatus = true,
        },
      })

      vim.lsp.enable("pyright")
      vim.lsp.enable("gopls")
      vim.lsp.enable("rust_analyzer")
      vim.lsp.enable("clangd")
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
      ensure_installed = { "python", "go", "lua", "java", "rust", "c", "cpp" },
      highlight = { enable = true },
    },
  },

  -- Indent guides + active scope
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = function()
      local hooks = require("ibl.hooks")

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "IblIndent", { fg = "#5a524c", nocombine = true })
        vim.api.nvim_set_hl(0, "IblScope", { fg = "#a89984", nocombine = true })
      end)

      return {
        indent = {
          char = "│",
          tab_char = "│",
          highlight = "IblIndent",
        },
        scope = {
          enabled = true,
          show_start = false,
          show_end = false,
          highlight = "IblScope",
        },
        whitespace = {
          remove_blankline_trail = true,
        },
        exclude = {
          buftypes = { "terminal", "nofile", "prompt", "quickfix" },
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "lazy",
            "mason",
            "neo-tree",
            "notify",
            "snacks_dashboard",
            "snacks_notif",
            "snacks_terminal",
            "TelescopePrompt",
            "Trouble",
          },
        },
      }
    end,
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

  -- Neo-tree (VS Code-like sidebar explorer)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = { "Neotree" },
    keys = {
      {
        "<leader>e",
        function()
          local root = require("config.project_root").get_root(0)
          require("neo-tree.command").execute({
            toggle = true,
            dir = root,
            position = "left",
            source = "filesystem",
          })
        end,
        desc = "Toggle Explorer (Neo-tree)",
      },
      {
        "<leader>er",
        function()
          require("neo-tree.command").execute({
            reveal = true,
            position = "left",
            source = "filesystem",
          })
        end,
        desc = "Reveal current file (Neo-tree)",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      local neotree = require("neo-tree.command")

      require("neo-tree").setup({
        close_if_last_window = true,
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          window = {
            mappings = {
              ["a"] = {
                "add",
                config = {
                  show_path = "none",
                },
              },
              ["A"] = "add_directory",
            },
          },
          follow_current_file = {
            enabled = true,
          },
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_gitignored = true,
            hide_dotfiles = false,
          },
        },
        window = {
          position = "left",
          width = 34,
        },
      })

      vim.api.nvim_create_autocmd("VimEnter", {
        once = true,
        callback = function()
          local argv0 = vim.fn.argv(0)
          if argv0 ~= "" and vim.fn.isdirectory(argv0) == 1 then
            vim.fn.chdir(argv0)
            neotree.execute({
              action = "show",
              dir = argv0,
              position = "left",
              source = "filesystem",
            })
          end
        end,
      })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
    end,
  },
    -- {
    --   "windwp/nvim-autopairs",
    --   config = function()
    --     local npairs = require("nvim-autopairs").setup({})
    --     local Rule = require("nvim-autopairs.rule")
    --     npairs.setup({
    --         check_ts = true, -- use treesitter
    --     })
    --     -- For rust specific < > 
    --     npairs.add_rules({
    --         Rule("<", ">", "rust")
    --             :with_pair(function(opts)
    --                 return opts.line:match("[%w_]+%s*<$") ~= nil
    --             end),
    --     })
    --   end,
    -- },
    --
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter", -- IMPORTANT: ensures plugin loads
      config = function()
        local ok, npairs = pcall(require, "nvim-autopairs")
        if not ok then return end

        local Rule = require("nvim-autopairs.rule")

        npairs.setup({
          check_ts = true,
        })

        npairs.add_rules({
          Rule("<", ">", "rust")
            :with_pair(function(opts)
              return opts.line:match("[%w_:]+%s*<$") ~= nil
            end),
        })
      end,
    },

    -- when claude changes files, refresh buffers smartly
    -- this does not reload buffers that have been changed
    {
    'diogo464/hotreload.nvim',
    opts = {}  -- Uses fs_event watchers by default
    },

    -- adding discord presence for fun!
    -- {
    --     'vyfor/cord.nvim',
    --     config = function()
    --         require('cord').setup({
    --             editor = {
    --                 name = "nvim",
    --                 tooltip = 'vim',
    --             },
    --             display = {
    --                 swap_fields = true,
    --             },
    --         })
    --     end
    -- }

}
