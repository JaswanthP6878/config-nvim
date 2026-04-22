local M = {}

local ROOT_MARKERS = {
  ".git",
  "mvnw",
  "gradlew",
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "pyproject.toml",
  "go.mod",
  "package.json",
  "CMakeLists.txt",
  "compile_commands.json",
  ".clangd",
  "Makefile",
}

function M.get_root(bufnr)
  bufnr = bufnr or 0

  local start = vim.api.nvim_buf_get_name(bufnr)
  if start == "" then
    start = vim.loop.cwd()
  end

  local root = vim.fs.root(start, ROOT_MARKERS)
  if root and root ~= "" then
    return root
  end

  return vim.loop.cwd()
end

return M
