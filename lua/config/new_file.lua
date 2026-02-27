local M = {}

local project_root = require("config.project_root")

local function is_absolute(path)
  return path:match("^/") ~= nil or path:match("^%a:[/\\]") ~= nil
end

function M.create_from_prompt()
  local root = project_root.get_root(0)

  vim.ui.input({ prompt = "New file path: " }, function(input)
    if not input or input == "" then
      return
    end

    local path = vim.fn.trim(input)
    if path == "" then
      return
    end

    local target
    if is_absolute(path) then
      target = path
    else
      target = vim.fs.normalize(root .. "/" .. path)
    end

    local dir = vim.fn.fnamemodify(target, ":h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end

    vim.cmd.edit(vim.fn.fnameescape(target))
  end)
end

return M
