local M = {}

-- Fuzzy-pick a local or remote-tracking branch, most recently committed first.
-- on_select receives { refname = "refs/remotes/origin/x", name = "origin/x" }.
-- base_of(refname) names the ref the preview lists commits since, so the preview shows
-- exactly the commits a merge-base diff against that ref will contain.
M.pick = function(on_select, base_of)
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local previewers = require "telescope.previewers"
  local putils = require "telescope.previewers.utils"
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"
  local entry_display = require "telescope.pickers.entry_display"
  local conf = require("telescope.config").values

  local out = vim.system({
    "git", "for-each-ref", "--sort=-committerdate",
    "--format=%(refname)%00%(refname:short)%00%(symref)%00%(committerdate:relative)%00%(subject)",
    "refs/heads", "refs/remotes",
  }, { text = true }):wait()
  if out.code ~= 0 then
    vim.notify("git for-each-ref failed: " .. vim.trim(out.stderr), vim.log.levels.ERROR)
    return
  end

  local branches, name_width, date_width = {}, 0, 0
  for _, line in ipairs(vim.split(out.stdout, "\n", { trimempty = true })) do
    local refname, name, symref, date, subject = unpack(vim.split(line, "\0", { plain = true }))
    -- origin/HEAD is an alias of another listed branch.
    if symref == "" then
      table.insert(branches, { refname = refname, name = name, date = date, subject = subject })
      name_width = math.max(name_width, #name)
      date_width = math.max(date_width, #date)
    end
  end

  local displayer = entry_display.create {
    separator = "  ",
    items = { { width = name_width }, { width = date_width }, { remaining = true } },
  }

  pickers.new({
    layout_strategy = "vertical",
    layout_config = { width = 0.87, height = 0.8, prompt_position = "bottom", preview_cutoff = 30 },
  }, {
    prompt_title = "Branch",
    finder = finders.new_table {
      results = branches,
      entry_maker = function(branch)
        return {
          value = branch,
          ordinal = branch.name,
          display = function()
            return displayer {
              { branch.name, "TelescopeResultsIdentifier" },
              { branch.date, "TelescopeResultsComment" },
              branch.subject,
            }
          end,
        }
      end,
    },
    sorter = conf.generic_sorter {},
    previewer = previewers.new_buffer_previewer {
      title = "Commits since merge-base",
      get_buffer_by_name = function(_, entry)
        return entry.value.refname
      end,
      define_preview = function(self, entry)
        local base = base_of(entry.value.refname)
        putils.job_maker(
          { "git", "--no-pager", "log", "--oneline", "--max-count=1000", base .. ".." .. entry.value.refname },
          self.state.bufnr,
          { value = entry.value.refname, bufname = self.state.bufname }
        )
      end,
    },
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          on_select(entry.value)
        end
      end)
      return true
    end,
  }):find()
end

return M
