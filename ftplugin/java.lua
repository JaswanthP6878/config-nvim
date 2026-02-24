local jdtls = require("jdtls")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local root_dir = vim.fs.root(0, { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" })
if not root_dir then
  vim.notify("jdtls: no Java project root found (missing .git/mvnw/gradlew/pom.xml/build.gradle)", vim.log.levels.WARN)
  return
end

-- Unique workspace per project (based on project root folder name)
local project_name = vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.stdpath("data") .. "/jdtls/workspaces/" .. project_name

-- Use Mason's jdtls wrapper script — it handles the launcher jar,
-- platform config dir, and all JVM flags automatically.
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin/jdtls"
local mason_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

-- Java 21 is required by jdtls to run itself. Your project still targets
-- whatever version is in pom.xml/build.gradle — this only affects jdtls.
local java21 = "/opt/homebrew/opt/openjdk@21/bin/java"

-- Build cmd: start with the wrapper, add workspace, then optional extras
local cmd = { mason_bin, "--java-executable", java21, "-data", workspace_dir }

-- Lombok support: add as javaagent if the jar is present
local lombok_jar = vim.fn.glob(mason_path .. "/lombok.jar")
if lombok_jar ~= "" then
  table.insert(cmd, "--jvm-arg=-javaagent:" .. lombok_jar)
end

-- Spring Boot Tools extension jars (if installed via Mason)
local spring_boot_path = vim.fn.stdpath("data") .. "/mason/packages/spring-boot-tools"
local bundles = {}
local spring_jars = vim.fn.glob(spring_boot_path .. "/extension/jars/*.jar", true, true)
vim.list_extend(bundles, spring_jars)

local config = {
  cmd = cmd,
  root_dir = root_dir,
  capabilities = capabilities,
  init_options = {
    bundles = bundles,
  },
  settings = {
    java = {
      signatureHelp = { enabled = true },
      completion = {
        favoriteStaticMembers = {
          "org.junit.Assert.*",
          "org.junit.jupiter.api.Assertions.*",
          "org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*",
        },
      },
      sources = {
        organizeImports = {
          starThreshold = 9999,
          staticStarThreshold = 9999,
        },
      },
    },
  },
}

jdtls.start_or_attach(config)

-- Java-specific keymaps (buffer-local, only active in Java files)
local opts = { buffer = true, silent = true }
vim.keymap.set("n", "<leader>oi", jdtls.organize_imports,                      vim.tbl_extend("force", opts, { desc = "Organize imports" }))
vim.keymap.set("n", "<leader>f",  vim.lsp.buf.format,                          vim.tbl_extend("force", opts, { desc = "Format file" }))
vim.keymap.set("v", "<leader>ev", function() jdtls.extract_variable(true) end, vim.tbl_extend("force", opts, { desc = "Extract variable" }))
vim.keymap.set("v", "<leader>em", function() jdtls.extract_method(true) end,   vim.tbl_extend("force", opts, { desc = "Extract method" }))
vim.keymap.set("n", "<leader>tc", function() jdtls.test_class() end,           vim.tbl_extend("force", opts, { desc = "Test class" }))
vim.keymap.set("n", "<leader>tm", function() jdtls.test_nearest_method() end,  vim.tbl_extend("force", opts, { desc = "Test nearest method" }))

-- Code generation
vim.keymap.set("n", "<leader>gc", function()
  vim.lsp.buf.code_action({ context = { only = { "source.generate.constructor" } }, apply = false })
end, vim.tbl_extend("force", opts, { desc = "Generate constructor" }))

vim.keymap.set("n", "<leader>gg", function()
  vim.lsp.buf.code_action({ context = { only = { "source.generate.accessors" } }, apply = false })
end, vim.tbl_extend("force", opts, { desc = "Generate getters/setters" }))

vim.keymap.set("n", "<leader>gt", function()
  vim.lsp.buf.code_action({ context = { only = { "source.generate.toString" } }, apply = false })
end, vim.tbl_extend("force", opts, { desc = "Generate toString" }))
