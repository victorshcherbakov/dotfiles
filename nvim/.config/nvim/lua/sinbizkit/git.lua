local M = {}

M.user_email = function()
  local def_value = "victor"
  local handle = io.popen "git config --get user.email"
  if handle == nil then
    return def_value
  end
  local result = handle:read "*a"
  handle:close()
  result = string.gsub(result, "\n", "")
  return #result > 0 and result or def_value
end

-- master of the remote a branch belongs to: one repository can hold unrelated histories from
-- several remotes, and only that remote's master shares a merge-base with the branch.
-- refname is a full ref (refs/heads/x, refs/remotes/r/x). A local branch goes by the remote
-- it tracks; no upstream, a local upstream or anything else falls back to origin.
M.parent_master = function(refname)
  local remote_branch = refname:match "^refs/remotes/(.+)$"
  if remote_branch then
    -- Remote names may contain "/", so match against the configured ones instead of splitting
    -- at the first slash. git refuses a remote name that prefixes another, so one match at most.
    local remotes = vim.system({ "git", "remote" }, { text = true }):wait()
    for _, remote in ipairs(vim.split(remotes.stdout or "", "\n", { trimempty = true })) do
      if vim.startswith(remote_branch, remote .. "/") then
        return remote .. "/master"
      end
    end
    return "origin/master"
  end

  local branch = refname:match "^refs/heads/(.+)$"
  if branch then
    local remote = vim.system({ "git", "config", "branch." .. branch .. ".remote" }, { text = true }):wait()
    if remote.code == 0 and vim.trim(remote.stdout) ~= "." then
      return vim.trim(remote.stdout) .. "/master"
    end
  end
  return "origin/master"
end

return M
