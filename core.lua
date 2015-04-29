local addonName, addon = ...

--[[
I think UNIT_POWER_BAR_SHOW and UNIT_POWER_BAR_HIDE relate to the UnitPowerBarAlt frame.
See: http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitPowerBarAlt.lua

http://wowpedia.org/COMBAT_LOG_EVENT. Is destGUID etc. actually set for a SPELL_CAST_START event?
]]

addon._G = _G
NinjaKittyUF = addon

--NinjaKittyUF = LibStub("AceAddon-3.0"):NewAddon("NinjaKittyUF", "AceConsole-3.0")
--NinjaKittyUF._G = _G

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

  local function hideBlizzardUnitFrame(frame)
    _G.assert(not _G.InCombatLockdown())
    frame:UnregisterAllEvents()
    frame.healthbar:UnregisterAllEvents()
    frame.manabar:UnregisterAllEvents()
    if frame.spellbar then frame.spellbar:UnregisterAllEvents() end
    frame:HookScript("OnUpdate", function() _G.error() end)
    frame:HookScript("OnEvent", function() _G.error() end)
    frame:Hide()
  end

  hideBlizzardUnitFrame(_G.PlayerFrame)
  hideBlizzardUnitFrame(_G.TargetFrame)
  hideBlizzardUnitFrame(_G.TargetFrameToT)
  hideBlizzardUnitFrame(_G.FocusFrame)
  hideBlizzardUnitFrame(_G.FocusFrameToT)
  _G.ComboFrame:UnregisterAllEvents(); _G.ComboFrame:Hide()
  _G.BuffFrame:UnregisterAllEvents(); _G.BuffFrame:Hide()
  _G.ConsolidatedBuffs:Hide()
  _G.TemporaryEnchantFrame:Hide()
  _G.CastingBarFrame:UnregisterAllEvents()
  -- This also seems to prevent _G.BuffTiimer1 from being shown. TODO: do we need to replace it?
  _G.PlayerPowerBarAlt:UnregisterAllEvents()
  _G.PlayerPowerBarAlt:HookScript("OnShow", function(self)
    self:Hide()
  end)
  _G.PlayerPowerBarAlt:Hide()
  _G.UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- ShadowedUnitFrames does this.
  for i = 1, _G.MAX_PARTY_MEMBERS do
    _G["PartyMemberFrame" .. i]:UnregisterAllEvents()
    _G["PartyMemberFrame" .. i]:Hide()
    _G["PartyMemberFrame" .. i]:HookScript("OnShow", function(self)
      if not _G.InCombatLockdown() then
        self:Hide()
      end
    end)
  end

  for _, v in _G.ipairs(frameAttributes) do
    v:create()
  end

  ----------------------------------------------------------------------------------------------------------------------
  -- Define special behaviour for some of the unit frames we just created.
  ----------------------------------------------------------------------------------------------------------------------

  --[=[
  do -- Hide the party frames when in a raid group of at least 6 members.
    local frame = _G.CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerStateTemplate")
    for i = 1, 4 do
      frame:SetFrameRef("NKParty" .. i .. "Frame", _G["NKParty" .. i .. "Frame"])
    end
    _G.RegisterStateDriver(frame, "raid6exists", "[@raid6,exists]exists;noexists")
    frame:SetAttribute("_onstate-raid6exists", [[ -- arguments: self, stateid, newstate
      if newstate == "exists" then
        for i = 1, 4 do
          UnregisterUnitWatch(self:GetFrameRef("NKParty" .. i .. "Frame"))
          self:GetFrameRef("NKParty" .. i .. "Frame"):Hide()
        end
      elseif newstate == "noexists" then
        for i = 1, 4 do
          RegisterUnitWatch(self:GetFrameRef("NKParty" .. i .. "Frame"))
          self:GetFrameRef("NKParty" .. i .. "Frame"):Show()
        end
      end
    ]])
    frame:Execute([[
      stateid, newstate = "raid6exists", UnitExists("raid6") and "exists" or "noexists"
      self:RunAttribute("_onstate-raid6exists")
    ]])
  end
  --]=]

  do
    -- I think we can't wrap script handlers of a frame that isn't explicitly protected (i.e.
    -- CompactRaidFrameContainer), but creating an explicitly protected child frame and wrapping its handlers works.
    local proxyFrame = _G.CreateFrame("Frame", nil, _G.CompactRaidFrameContainer, "SecureHandlerBaseTemplate")

    local header = _G.CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerBaseTemplate")

    for i = 1, 4 do
      header:SetFrameRef("NKParty" .. i .. "Frame", _G["NKParty" .. i .. "Frame"])
    end

    header:Execute([[
      partyFrames = table.new()
      for i = 1, 4 do
        table.insert(partyFrames, self:GetFrameRef("NKParty" .. i .. "Frame"))
      end
    ]])

    header:WrapScript(proxyFrame, "OnShow", [[
      print("foo2")
      for i = 1, 4 do
        UnregisterUnitWatch(partyFrames[i])
        partyFrames[i]:Hide()
      end
    ]])

    header:WrapScript(proxyFrame, "OnHide", [[
      print("bar2")
      for i = 1, 4 do
        RegisterUnitWatch(partyFrames[i])
        partyFrames[i]:Show()
      end
    ]])
  end

  self.ADDON_LOADED = nil
end

handlerFrame:RegisterEvent("ADDON_LOADED")

-- vim: tw=120 sts=2 sw=2 et
