local TextUtils = {}

function TextUtils.doCtrlChar(self, state, func, ...)

  if state.kb.ctrl then
    func(self, ... and table.unpack({...}))

    -- Flag to bypass the "clear selection" logic in :onType()
    return true

  else
    self:insertChar(state.kb.char)
  end

end

function TextUtils.toClipboard(self, cut)
  if self.selectionStart and self:SWS_clipboard() then

    local str = self:getSelectedText()
    reaper.CF_SetClipboard(str)
    if cut then self:deleteSelection() end

  end

end

function TextUtils.fromClipboard(self)

  if self:SWS_clipboard() then

    local fastStr = reaper.SNM_CreateFastString("")
    local str = reaper.CF_GetClipboardBig(fastStr)
    reaper.SNM_DeleteFastString(fastStr)

    self:insertString(str, true)

  end

end

function TextUtils.undo(self)

  if #self.undoStates == 0 then return end
  table.insert(self.redoStates, self:getEditorState() )
  local state = table.remove(self.undoStates)

  self.retval = state.retval
  self.caret = state.caret

  self:setWindowToCaret()

end

function TextUtils.storeUndoState(self)

  table.insert(self.undoStates, self:getEditorState() )
  if #self.undoStates > self.undoLimit then table.remove(self.undoStates, 1) end
  self.redoStates = {}

end

-- See if we have a new-enough version of SWS for the clipboard functions
-- (v2.9.7 or greater)
function TextUtils.SWS_clipboard(self)

  if (Scythe.hasSWS and reaper.CF_GetClipboardBig) then
    return true
  else

    reaper.ShowMessageBox(
      "Clipboard functions require the SWS extension, v2.9.7 or newer."..
      "\n\nDownload the latest version at http://www.sws-extension.org/index.php",

      "Sorry!",
      0
    )
    return false

  end

end

return TextUtils
