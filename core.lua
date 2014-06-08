--[[
I think UNIT_POWER_BAR_SHOW and UNIT_POWER_BAR_HIDE relate to the UnitPowerBarAlt frame.
See: http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitPowerBarAlt.lua

http://wowpedia.org/COMBAT_LOG_EVENT.  Is destGUID etc. actually set for a SPELL_CAST_START event?
]]

NinjaKittyUF = LibStub("AceAddon-3.0"):NewAddon("NinjaKittyUF", "AceConsole-3.0")
NinjaKittyUF._G = _G

setfenv(1, NinjaKittyUF)

local handlerFrame = _G.CreateFrame("Frame")

handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event](self, ...)
end)

function handlerFrame:ADDON_LOADED(name)
  self:UnregisterEvent("ADDON_LOADED")

  for _, v in _G.ipairs(frameAttributes) do
    v:create()
  end

  self.ADDON_LOADED = nil
end

handlerFrame:RegisterEvent("ADDON_LOADED")

-- vim: tw=100 sw=2 et
