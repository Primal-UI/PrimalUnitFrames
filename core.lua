--[[
I think UNIT_POWER_BAR_SHOW and UNIT_POWER_BAR_HIDE relate to the UnitPowerBarAlt frame.
See: http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitPowerBarAlt.lua

http://wowpedia.org/COMBAT_LOG_EVENT.  Is destGUID etc. actually set for a SPELL_CAST_START event?
]]

NinjaKittyUF = LibStub("AceAddon-3.0"):NewAddon("NinjaKittyUF", "AceConsole-3.0")
NinjaKittyUF._G = _G

setfenv(1, NinjaKittyUF)

-- http://wowprogramming.com/docs/api_types#specID
-- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitFrame.lua
-- The names of global variables containing the localized name of the power type by specID. Can be
-- used to index the PowerBarColor table defined in "FrameXML/UnitFrame.lua".
powerTokens = {
  [62] = "MANA", [63] = "MANA", [64] = "MANA", -- Mage
  [65] = "MANA", [66] = "MANA", [70] = "MANA", -- Paladin
  [71] = "RAGE", [72] = "RAGE", [73] = "RAGE", -- Warrior
  [102] = "MANA", [103] = "MANA", [104] = "MANA", [105] = "MANA", -- Druid
  [250] = "RUNIC_POWER", [251] = "RUNIC_POWER", [252] = "RUNIC_POWER", -- Death Knight
  [253] = "FOCUS", [254] = "FOCUS", [255] = "FOCUS", -- Hunter
  [256] = "MANA", [257] = "MANA", [258] = "MANA", -- Priest
  [259] = "ENERGY", [260] = "ENERGY", [261] = "ENERGY", -- Rogue
  [262] = "MANA", [263] = "MANA", [264] = "MANA", -- Shaman
  [265] = "MANA", [266] = "MANA", [267] = "MANA", -- Warlock
  [268] = "ENERGY", [269] = "ENERGY", [270] = "MANA", -- Monk
}

-- Should be defined in Blizzard_ArenaUI.lua:
-- http://wowprogramming.com/utils/xmlbrowser/live/AddOns/Blizzard_ArenaUI/Blizzard_ArenaUI.lua
if not _G["MAX_ARENA_ENEMIES"] then _G["MAX_ARENA_ENEMIES"] = 5 end

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
