local M = {}

local function package_from_path(path)
  if not path or path == "" then
    return nil
  end

  local normalized = path:gsub("\\", "/")
  local package_path = normalized:match("/src/main/java/(.+)/[^/]+%.java$")
    or normalized:match("/src/test/java/(.+)/[^/]+%.java$")

  if not package_path or package_path == "" then
    return nil
  end

  return package_path:gsub("/", ".")
end

local function class_name_from_buf()
  local name = vim.fn.expand("%:t:r")
  name = name:gsub("[^%w_$]", "")
  if name == "" then
    name = "Main"
  elseif name:match("^[%d]") then
    name = "_" .. name
  end
  return name
end

local function is_buffer_empty(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return #lines == 1 and lines[1] == ""
end

local function insert_java_template(bufnr)
  if not is_buffer_empty(bufnr) then
    return
  end

  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local package_name = package_from_path(file_path)
  local class_name = class_name_from_buf()
  local lines = {}

  if package_name then
    table.insert(lines, "package " .. package_name .. ";")
    table.insert(lines, "")
  end

  table.insert(lines, "public class " .. class_name .. " {")
  table.insert(lines, "")
  table.insert(lines, "}")

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

  local target_line = package_name and 4 or 2
  vim.api.nvim_win_set_cursor(0, { target_line, 2 })
end

function M.setup()
  local group = vim.api.nvim_create_augroup("JavaNewFileTemplate", { clear = true })

  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    pattern = "*.java",
    callback = function(args)
      insert_java_template(args.buf)
    end,
  })
end

return M
