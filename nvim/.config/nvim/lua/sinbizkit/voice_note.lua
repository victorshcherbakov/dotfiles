-- Dictated review notes: toggle records the microphone, whisper.cpp transcribes it
-- and the text lands in notes_file tagged with the cursor position, as a task list
-- for Claude. Binary and model come from mydotfiles/script/whisper.sh.
local M = {}

local notes_file = vim.fn.expand "~/.local/state/voice-notes/notes.md"
local model_file = vim.fn.expand "~/.local/share/whisper/ggml-large-v3-turbo-q5_0.bin"
local vad_model_file = vim.fn.expand "~/.local/share/whisper/ggml-silero-v6.2.0.bin"

local recording_process = nil -- vim.SystemObj of pw-record while recording

local function append_note(location, text)
  vim.fn.mkdir(vim.fn.fnamemodify(notes_file, ":h"), "p")
  local file = assert(io.open(notes_file, "a"))
  file:write("- ", location and (location .. " — ") or "", text, "\n")
  file:close()
end

-- A diffview side buffer holds a non-working-tree version of the file, so its line
-- numbers are valid only together with that commit / index stage.
local function diffview_revision(bufnr)
  local lib = package.loaded["diffview.lib"]
  local view = lib and lib.get_current_view()
  if not (view and view.cur_layout) then
    return nil
  end
  for _, file in ipairs(view.cur_layout:files()) do
    -- A nulled file is the empty side of an added / deleted file: nothing to point at.
    if file.bufnr == bufnr and not file.nulled and file.rev.type ~= require("diffview.vcs.rev").RevType.LOCAL then
      return file.absolute_path, file.rev:object_name(11)
    end
  end
  return nil
end

local function cursor_location(first_line, last_line)
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = first_line == last_line and tostring(first_line) or (first_line .. "-" .. last_line)
  local path, revision = diffview_revision(bufnr)
  if path then
    return string.format("`%s:%s` (version %s)", path, lines, revision)
  end
  if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
    return nil
  end
  return string.format("`%s:%s`", vim.api.nvim_buf_get_name(bufnr), lines)
end

local function transcribe(wav_file, location)
  vim.notify "voice: transcribing..."
  local command = { "whisper-cli", "-m", model_file, "--vad", "-vm", vad_model_file, "-l", "ru", "-nt", "-np",
    "-t", tostring(vim.uv.available_parallelism()), "-f", wav_file }
  vim.system(command, { text = true }, function(whisper)
    os.remove(wav_file)
    vim.schedule(function()
      local text = vim.trim((whisper.stdout or ""):gsub("%s+", " "))
      if whisper.code ~= 0 then
        vim.notify("voice: whisper-cli failed\n" .. (whisper.stderr or ""), vim.log.levels.ERROR)
        return
      end
      if text == "" then
        vim.notify("voice: no speech recognized", vim.log.levels.WARN)
        return
      end
      append_note(location, text)
      vim.notify("voice: " .. text)
    end)
  end)
end

M.toggle = function()
  if recording_process then
    recording_process:kill "sigint"
    recording_process = nil
    return
  end

  local first_line, last_line = vim.fn.line ".", vim.fn.line "."
  if vim.fn.mode():match "^[vV\22]" then
    first_line, last_line = math.min(vim.fn.line "v", first_line), math.max(vim.fn.line "v", first_line)
    vim.api.nvim_feedkeys(vim.keycode "<Esc>", "nx", false)
  end
  local location = cursor_location(first_line, last_line)
  local wav_file = vim.fn.tempname() .. ".wav"

  -- pw-record exits with code 1 on SIGINT but still finalizes a valid wav header.
  recording_process = vim.system({ "pw-record", "--rate", "16000", "--channels", "1", "--format", "s16", wav_file }, {},
    vim.schedule_wrap(function() transcribe(wav_file, location) end))
  vim.notify("voice: recording, " .. (location or "no location") .. " — press again to stop")
end

return M
