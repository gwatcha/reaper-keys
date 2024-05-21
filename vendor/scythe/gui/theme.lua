local Theme = {}

Theme.colors = {
  background = {64, 64, 64, 255},
  backgroundDark = {56, 56, 56, 255},
  backgroundDarkest = {48, 48, 48, 255},
  elementBody = {96, 96, 96, 255},
  highlight = {64, 192, 64, 255},
  elementOutline = {32, 32, 32, 255},
  text = {192, 192, 192, 255},
  shadow = {0, 0, 0, 48},
  faded = {0, 0, 0, 64},
}

local osFonts = {
  Windows = {
    sans = "Calibri",
    mono = "Lucida Console"
  },
  OSX = {
    sans = "Helvetica Neue",
    mono = "Andale Mono"
  },
  Linux = {
    sans = "Liberation Sans",
    mono = "Liberation Mono"
  }
}

local os = reaper.GetOS()
local fonts = (os:match("Win") and osFonts.Windows)
  or (os:match("OSX") and osFonts.OSX)
  or osFonts.Linux

Theme.fonts = {
              -- Font,    size, bold/italics/underline
              --                i.e. "b", "iu", etc.
              {fonts.sans, 32},                         -- 1. Title
              {fonts.sans, 20},                         -- 2. Header
              {fonts.sans, 16},                         -- 3. Label
              {fonts.sans, 16},                         -- 4. Value
  monospace = {fonts.mono, 14},
  version =   {fonts.sans, 12, "i"},
}

local ext = reaper.GetExtState("Scythe v3", "userTheme")

local function parseQueryString(str)
  return str:split("&"):reduce(function(acc, param)
    local k, v = param:match("([^=]+)=([^=]+)")
    if k and v then acc[k] = v end

    return acc
  end, {})
end

local userTheme = parseQueryString(ext)

for k, v in pairs(userTheme) do
  if Theme[k] ~= nil then Theme[k] = v end
end

return Theme
