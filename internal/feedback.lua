local Font = require 'public.font'
local GUI = require 'gui.core'
local config = require 'definitions.config'
local gui_utils = require 'gui.utils'
local reaper_state = require 'reaper_state'
local scale = gui_utils.scale
local utils = require 'utils'

local feedbackWindow = {}

function feedbackWindow:updateElementDimensions()
    Font.set("feedback_main")
    local _, char_h = gfx.measurestr("i")
    local props = self.props
    local pad = scale(props.elements.padding)

    local message_h = char_h + 2 * pad
    self.message_h = message_h

    local window = self.window
    local completions_height = window.h - message_h
    local elements = self.elements

    elements.completions.h = completions_height
    elements.completions.pad = pad
    elements.completions.w = window.w
    elements.completions.y = message_h

    elements.message.y = 0
    elements.message.h = message_h
    elements.message.w = window.w
    elements.message.pad = pad
end

local function createElements()
    local layer = GUI.createLayer { name = "Main Layer" }
    layer:addElements(GUI.createElements(
        { type = "Frame", name = "message", font = "feedback_main" },
        {
            type = "Frame",
            name = "completions",
            font = "feedback_main",
            bg = "backgroundDarkest",
            completions = {},
        }
    ))
    return layer
end

local function drawMessage(self)
    if not self.message or not self.extra_info or not self.mode then
        return
    end

    gfx.x, gfx.y = self.pad + 1, self.pad + 1
    gui_utils.styled_draw(self.message, "feedback_main", "text")

    if self.extra_info ~= "" then
        gui_utils.styled_draw("  " .. self.extra_info, "feedback_main", self.props.colors.extra_info)
    end

    if self.mode ~= "normal" then
        local mode_str_w = gfx.measurestr(self.mode)
        gfx.x = self.w - mode_str_w - self.pad
        local mode_color = self.props.colors[self.mode]
        gui_utils.styled_draw(self.mode, "feedback_main", mode_color)
    end
end

local function valMessage(self, message, extra_info, mode)
    self.message = message
    self.extra_info = extra_info
    self.mode = mode

    if self.buffer then self:init() end
    self:redraw()
end

local function getMaxKeyWidth(completions)
  local max_key_width = 0
  for _,completion in pairs(completions) do
    Font.set("feedback_key")
    local key_width = gfx.measurestr(completion.key_sequence)
    if key_width > max_key_width then
      max_key_width = key_width
    end
  end

  return max_key_width
end

function table.slice(t, first, last)
  local sliced = {}

  local adjusted_last = last
  if not last or last > #t then
      adjusted_last = #t
  end

  for i = first or 1, adjusted_last, 1 do
    sliced[#sliced+1] = t[i]
  end

  return sliced
end

local function getCompletionPositions(self)
  local positions = {}
  local completions = self.completions
  if not completions then
    return positions, 0
  end

  Font.set("feedback_main")
  local _, char_h = gfx.measurestr("i")

  local row_pad = self.props.elements.row_padding
  local num_rows = math.floor((self.h - 2*self.pad) / (char_h + row_pad))
  if num_rows == 0 then
    return positions, 0
  end

  local num_cols = tonumber(#completions / num_rows)
  if #self.completions % num_rows > 0 then
    num_cols = num_cols + 1
  end

  local column_width = 0
  local column_pad = self.props.elements.column_padding
  local column_x = column_pad
  local required_w = 0

  for i=1,num_cols,1 do
    local start_i = (i - 1) * num_rows + 1

    local column_completions = table.slice(completions, start_i, start_i + num_rows - 1)
    local column_max_key_width = getMaxKeyWidth(column_completions)

    column_x = column_x + column_width + column_pad
    column_width = 0

    for current_row,completion in pairs(column_completions) do
      Font.set("feedback_key")
      local key_width = gfx.measurestr(completion.key_sequence)

      local row_width = column_max_key_width
      Font.set("feedback_arrow")
      row_width = row_width + gfx.measurestr(" -> ")
      if completion.folder == true then
        Font.set("feedback_folder")
        row_width = row_width + gfx.measurestr(completion.value)
      else
        Font.set("feedback_main")
        row_width = row_width + gfx.measurestr(completion.value)
      end

      local position = {
        x = column_x + (column_max_key_width - key_width),
        y = (current_row - 1) * (char_h + row_pad) + self.pad,
      }
      table.insert(positions, position)

      if row_width > column_width then
        column_width = row_width
      end
    end
  end

  required_w = column_x + column_width
  return positions, required_w
end

local function drawCompletions(self)
  local completions = self.completions
  if type(completions) == 'string' then return end
  if not completions then return end

  local positions = self:getCompletionPositions()
  for i,position in pairs(positions) do
    local completion = completions[i]
    gfx.x = position.x
    gfx.y = position.y
    gui_utils.styled_draw(completion.key_sequence, "feedback_key", self.props.colors.key)
    gui_utils.styled_draw(" -> ", "feedback_arrow", self.props.colors.arrow)
    if completion.folder == true then
      gui_utils.styled_draw(completion.value, "feedback_folder", self.props.colors.folder)
    else
      local action_type_color = self.props.action_type_colors[completion.action_type]
      gui_utils.styled_draw(completion.value, "feedback_main", action_type_color)
    end
  end
end

local function valCompletions(self, completions)
  if completions then
    self.completions = completions
    if self.buffer then self:init() end
    self:redraw()
  else
    return self.completions
  end
end

local function getRequiredHeight(self)
  if not self.completions or #self.completions == 0 then
    return 0
  end

  local current_h = self.h
  Font.set("feedback_main")

  local _, char_h = gfx.measurestr("i")
  local row_pad = self.props.elements.row_padding

  local x,y = self.pad, self.pad

  local row_size = char_h + row_pad
  self.h = 100000
  local _, required_w = self:getCompletionPositions()
  self.h = current_h
  local max_column_width = required_w
  local num_columns = math.floor(self.w / max_column_width)

  local required_rows = math.ceil(#self.completions / num_columns)
  local required_height = required_rows * row_size + self.pad * 2

  return required_height
end

local feedback_table_name = "feedback"

local function createWindow(props)
    local settings = reaper_state.getKey(feedback_table_name, "window_settings") or {}
    local window = GUI.createWindow({
        name = "Reaper Keys Feedback",
        w = settings.w,
        x = settings.x,
        h = settings.h,
        y = settings.y,
        dock = config.general.dock_feedback_window and 1 or 0,
        corner = "TL"
    })

    local layer = createElements()
    window:addLayers(layer)

    local frame_element = GUI.findElementByName("completions")
    frame_element.props = props
    frame_element.drawText = drawCompletions
    frame_element.val = valCompletions
    frame_element.getRequiredHeight = getRequiredHeight
    frame_element.getCompletionPositions = getCompletionPositions

    frame_element = GUI.findElementByName("message")
    frame_element.props = props
    frame_element.val = valMessage
    frame_element.drawText = drawMessage

    return window
end

function feedbackWindow:new()
    local view = {}
    setmetatable(view, self)
    self.__index = self
    self.props = config.gui.feedback
    self.props.action_type_colors = config.gui.action_type_colors
    gui_utils.addFonts(self.props.fonts)
    self.window = createWindow(self.props)
    self.elements = {
        completions = GUI.findElementByName("completions"),
        message = GUI.findElementByName("message"),
    }
    self:updateElementDimensions()

    return view
end

function feedbackWindow:adjustWindow()
    local completions_h = self.elements.completions:getRequiredHeight()
    local new_h = self.message_h + completions_h
    local _, _, _, _, current_h = gfx.dock(-1, 0, 0, 0, 0)
    if new_h ~= current_h then
        self:redraw({ h = new_h })
    end
end

function feedbackWindow:updateCompletions(completions)
    self.elements.completions:val(completions)
    self:adjustWindow()
end

function feedbackWindow:updateMessage(model)
    self.elements.message:val(model.message, model.right_text, model.mode)
end

function feedbackWindow:open()
    local update_number = 0
    local show_after = self.props.show_after
    local completions_triggered = false
    local update_time = reaper.time_precise()

    local function main()
        local model = reaper_state.get(feedback_table_name)
        local completions = model.completions

        if model.update_number ~= update_number then
            update_time = reaper.time_precise()
            update_number = model.update_number
            self:updateMessage(model)

            if completions_triggered then
                self:updateCompletions(completions)
                if not completions or #completions == 0 then
                    completions_triggered = false
                end
            end
        else
            local delta = reaper.time_precise() - update_time
            if completions and #completions > 0 and not completions_triggered and delta >= show_after then
                completions_triggered = true
                self:updateCompletions(completions)
            end
        end

        if self.window.state.resized then
            self.window.state.resized = false
            self:redraw()
        end
    end

    self.window:open()
    GUI.func = main
    GUI.funcTime = 0
    GUI.Main()
end

function feedbackWindow:getWindowSettings()
    return gui_utils.getWindowSettings()
end

function feedbackWindow:redraw(params)
    if self.window.state then
        self.window.h = self.window.state.currentH
        self.window.w = self.window.state.currentW
        self.window:reopen(params)
    end

    self:updateElementDimensions()
    for _, element in pairs(self.elements) do
        if element.recalculateWindow then
            element:recalculateWindow()
        end
        element:init()
        element:redraw()
    end
end

local feedback = {}

---@param key string
---@return string
local function removeUglyBrackets(key)
    if key:sub(1, 1) == "<" and key:sub(#key, #key) == ">" then
        return key:sub(2, #key - 1)
    end
    return key
end


---@param sequence string
---@return string
local function formatKeySequence(sequence)
    local rest = sequence
    local key_sequence_string = ""
    local first_key
    while #rest ~= 0 do
        first_key, rest = utils.splitFirstKey(rest)
        if tonumber(first_key) then
            key_sequence_string = key_sequence_string .. first_key
        else
            key_sequence_string = key_sequence_string .. " " .. removeUglyBrackets(first_key)
        end
    end

    return key_sequence_string .. "-"
end

function feedback.displayCompletions(future_entries, state_key_sequence)
    feedback.displayMessage(formatKeySequence(state_key_sequence))

    local completions = {}

    for action_type, future_entries_for_action_type in pairs(future_entries) do
        for key_sequence, entry_value in pairs(future_entries_for_action_type) do
            local completion = {}
            local duplicate_folder = false
            if utils.isFolder(entry_value) then
                completion.folder = true
                local folder_name = entry_value[1]
                completion.value = folder_name

                for _, v in pairs(completions) do
                    if v.folder and v.value == folder_name and v.key_sequence == key_sequence then
                        duplicate_folder = true
                        break
                    end
                end
            else
                completion.value = entry_value
            end

            completion.action_type = action_type
            completion.key_sequence = key_sequence

            if not completion.folder or not duplicate_folder then
                table.insert(completions, completion)
            end
        end

        table.sort(completions, function(a, b)
            if a.folder and not b.folder then return true end
            if not a.folder and b.folder then return false end
            if not a.folder and not b.folder and a.action_type ~= b.action_type then
                return a.action_type > b.action_type
            end
            return a.value < b.value
        end)

        reaper_state.setKeys(feedback_table_name, { completions = completions })
    end
end

local startup_msg =
    "Hello from inside Reaper Keys! I see the feedback window just opened... " ..
    "Here are some things I have been told to tell you:\n" ..
    "- If the feedback window is focused and not docked, I can't hear keys being pressed, be sure to unfocus it.\n" ..
    "- Press <CM-x> (Ctrl + Alt + x) to open up a keybinding menu.\n" ..
    "- Everything you need to configure reaper-keys is in REAPER/Scripts/reaper-keys/internal/definitions/\n" ..
    "- If you would like to hide this message, set the option in internal/definitions/config.lua\n" ..
    "\t Your mother loves you"
local feedback_view = nil

---@param state State
function feedback.displayState(state)
    local right_text = state.macro_recording and ("(rec %s..)"):format(state.macro_register) or ""
    reaper_state.setKeys(feedback_table_name, { right_text = right_text, mode = state.mode })

    local feedback_view_open = reaper_state.getKey(feedback_table_name, "open")
    -- TODO hack with direct namespace access
    local just_opened = false
    if reaper.GetExtState("reaper_keys", "reaper_started") ~= "open" then
        reaper.SetExtState("reaper_keys", "reaper_started", "open", false)
        just_opened = true
    end

    if feedback_view_open and not just_opened then
        local update_number = tonumber(reaper_state.getKey(feedback_table_name, "update_number") or 0)
        if update_number > 20 then update_number = 0 end
        reaper_state.setKeys(feedback_table_name, { update_number = update_number + 1 })
        return
    end

    feedback_view = feedbackWindow:new()
    feedback_view:open()

    if config.general.show_start_up_message then
        reaper.ShowMessageBox(startup_msg, "Reaper Keys Open Message", 1)
    end

    reaper_state.setKeys(feedback_table_name, { open = true })

    if config.general.profile then
        local path = '/Scripts/ReaTeam Scripts/Development/cfillion_Lua profiler.lua'
        Profiler = dofile(reaper.GetResourcePath() .. path)
        Profiler.attachToWorld()
        Profiler.start()
        Profiler.run()
    end

    reaper.atexit(function()
        local window_settings = feedback_view:getWindowSettings()
        reaper_state.setKeys(feedback_table_name, { open = false, window_settings = window_settings })
    end)
end

function feedback.displayMessage(message)
    if not config.general.show_feedback_window then return end
    reaper_state.setKeys(feedback_table_name, { message = message })
end

function feedback.clear()
    reaper_state.setKeys(feedback_table_name, { message = "", completions = "", mode = "" })
end

function feedback.reset()
    reaper_state.setKeys(feedback_table_name, { open = false })
end

return feedback
