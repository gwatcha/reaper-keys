local gui = require 'definitions.config'.gui
local dock_feedback_window = require 'definitions.config'.general.dock_feedback_window
local gui_utils = require 'gui.utils'
local scale = gui_utils.scale
local createCompletionsElement = require 'gui.feedback.completions'
local createMessageElement = require 'gui.feedback.message'
local model_interface = require 'gui.feedback.model'
require 'scythe'
local Font = require 'public.font'
local GUI = require 'gui.core'
local reaper_state = require 'reaper_state'
View = {}

function View:updateElementDimensions()
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

local function createWindow(props)
    local settings = reaper_state.getFeedbackKey("window_settings") or {}
    local window = GUI.createWindow({
        name = "Reaper Keys Feedback",
        w = settings.w,
        x = settings.x,
        h = settings.h,
        y = settings.y,
        dock = dock_feedback_window and 1 or 0,
        corner = "TL"
    })

    local layer = createElements()
    window:addLayers(layer)

    local frame_element = GUI.findElementByName("completions")
    createCompletionsElement(frame_element, props)

    frame_element = GUI.findElementByName("message")
    createMessageElement(frame_element, props)

    return window
end

function View:new()
    local view = {}
    setmetatable(view, self)
    self.__index = self
    self.props = gui.feedback
    self.props.action_type_colors = gui.action_type_colors
    gui_utils.addFonts(self.props.fonts)
    self.window = createWindow(self.props)
    self.elements = {
        completions = GUI.findElementByName("completions"),
        message = GUI.findElementByName("message"),
    }
    self:updateElementDimensions()

    return view
end

function View:adjustWindow()
    local completions_h = self.elements.completions:getRequiredHeight()
    local new_h = self.message_h + completions_h
    local _, _, _, _, current_h = gfx.dock(-1, 0, 0, 0, 0)
    if new_h ~= current_h then
        self:redraw({ h = new_h })
    end
end

function View:updateCompletions(completions)
    self.elements.completions:val(completions)
    self:adjustWindow()
end

function View:updateMessage(model)
    self.elements.message:val(model.message, model.right_text, model.mode)
end

function View:open()
    local update_number = 0
    local show_after = self.props.show_after
    local hide_after = self.props.hide_after
    local completions_triggered = false
    local update_time = reaper.time_precise()

    local function main()
        local model = reaper_state.getFeedback()
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

            -- FIXME binding list doesn't proparate its name so it's also hidden
            --if self.window["dock"] == 0 and
            --    hide_after ~= 0 and delta >= hide_after and
            --    self.window["name"]:match "Feedback$" then
            --    require 'public.message'.Msg(self.window["name"])
            --    require 'gui.feedback.controller'.clear()
            --    self.window:close()
            --end
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

function View:getWindowSettings()
    return gui_utils.getWindowSettings()
end

function View:redraw(params)
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

return View
