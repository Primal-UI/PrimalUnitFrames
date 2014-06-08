setfenv(1, NinjaKittyUF)

settings = {
  epsilon = 0.001,
  spacing = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
  fontSpacing = 2,
  classColors = _G.RAID_CLASS_COLORS,
  unknownName = "Unknown",
  barTexture = [[Interface\AddOns\NinjaKittyUF\media\textures\plain_white]],
  defaultFont = _G.CreateFont("NKUFDefaultFont"),
  fontSize = 11,
  strings = {
    dead    = "Dead",
    ghost   = "Ghost",
    offline = "Offline",
  },
  colors = {
    background = { r = 0, g = 0, b = 0, a = 0.5, colorStr = "80000000" },
    casting = { r = 0.85, g = 0.25, b = 0.25, a = 0.75, colorStr = "bfd94040" },
    --casting = { r = 0.5, g = 0.5, b = 0.5, a = 0.75, colorStr = "bf808080" },
    --castingNotInterruptible = { r = 0.5, g = 0.0, b = 0.75, a = 0.75, colorStr = "bf8000bf" },
    castingNotInterruptible = { r = 0.75, g = 0.25, b = 0.85, a = 0.75, colorStr = "bfbf40d9" },
    dead = { r = 0.75, g = 0.75, b = 0.75, a = 0.25, colorStr = "40bfbfbf" },
    incomingHeals = { r = 0.5, g = 0.5, b = 0.5, a = 0.75, colorStr = "bf808080" },
    incomingDark = { r = 0.25, g = 0.25, b = 0.25, a = 0.75, colorStr = "bf404040" },
    health = { r = 0.85, g = 0.85, b = 0.85, a = 0.75, colorStr = "bfd9d9d9" },
    healthDark = { r = 0.4, g = 0.4, b = 0.4, a = 0.75, colorStr = "bf666666" },
    powerBarBackground = { r = 0, g = 0, b = 0, a = 0.75, colorStr = "bf000000" },
    noPower = { r = 0, g = 0, b = 0, a = 0.75, colorStr = "bf000000" },
    tapped = { r = 0.625, g = 0.625, b = 0.625, a = 1, colorStr = "ffa0a0a0" },
    offline = { r = 1, g = 1, b = 1, a = 1, colorStr = "ffffffff" },
  },
  powerAlpha = 0.75,
  offlineColor = "ffffffff",
  defaults = {},
  roles = {
    ["DAMAGER"] = "DPS",
    ["HEALER"] = "Healer",
    ["TANK"] = "Tank",
  },
}

settings.defaults.width = 208

----------------------------------------------------------------------------------------------------
-- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitFrame.lua
-- http://forums.wowace.com/showthread.php?t=18724
settings.powerColors = {}
for powerToken, color in _G.pairs(_G.PowerBarColor) do
  if color.r and color.g and color.b then
    settings.powerColors[powerToken] = { r = color.r, g = color.g, b = color.b,
                                         a = settings.powerAlpha }
    -- %02x means a hexadecimal number ('x'), with at least two digits and zero padding. The leading
    -- "ff" means the color should be fully opaque.
    settings.powerColors[powerToken].colorStr = _G.string.format("ff%02x%02x%02x", color.r * 255,
      color.g * 255, color.b * 255)
  end
end

-- Use a much lighter blue for mana.  "ff0000ff" is the default.  Shamans are "ff0070de", Mages are
-- "ff69ccf0". Runic Power is "ff00d1ff".  "ff4d80d9" is the color Shadowed UF used by default.
settings.powerColors["MANA"].colorStr = "ff8080ff"
settings.powerColors["MANA"].r = 0x80 / 0xff
settings.powerColors["MANA"].g = 0x80 / 0xff
settings.powerColors["MANA"].b = 0xff / 0xff
----------------------------------------------------------------------------------------------------

settings.defaultFont:SetFont([[Interface\AddOns\NinjaKittyMedia\fonts\Ubuntu-M.ttf]], 11, "")
settings.defaultFont:SetShadowColor(0.0, 0.0, 0.0, 1.0) -- Black and fully opaque.
settings.defaultFont:SetShadowOffset(1, -1)

settings.defaultBackdrop = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
}

-- See wowprogramming.com/docs/widgets/Frame/SetBackdrop and
-- http://wowprogramming.com/docs/api_types#backdrop.
settings.unitFrameBackdrop = {
  --bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
  edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", 
  --tile = false,
  edgeSize = 1,
}

settings.kittyPowerFrameBackdrop = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
  --edgeFile = [[Interface\\ChatFrame\\ChatFrameBackground]], 
  --edgeSize = 1,
}

settings.headerBarBackdrop = {
  --bgFile = "Interface\\AddOns\\NinjaKittyUF\\media\\textures\\plain_white",
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground", 
  --edgeFile = "Interface\\AddOns\\NinjaKittyUF\\media\\textures\\plain_white",
  --edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", 
  --[[
  tile = false,
  tileSize = 32,
  edgeSize = 32,
  insets = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  ]]
}

-- http://wowprogramming.com/docs/api_types#specID
settings.specNames = {
  [62]  = "Arcane",
  [63]  = "Fire",
  [64]  = "Frost",
  [65]  = "Holy",
  [66]  = "Prot",
  [70]  = "Ret",
  [71]  = "Arms",
  [72]  = "Fury",
  [73]  = "Prot",
  [102] = "Balance",
  [103] = "Feral",
  [104] = "Guardian",
  [105] = "Resto",
  [250] = "Blood",
  [251] = "Frost",
  [252] = "Unh",
  [253] = "BM",
  [254] = "MM",
  [255] = "Surv",
  [256] = "Disc",
  [257] = "Holy",
  [258] = "Shadow",
  [259] = "Ass",
  [260] = "Combat",
  [260] = "Sub",
  [262] = "Ele",
  [263] = "Enh",
  [264] = "Resto",
  [265] = "Aff",
  [266] = "Demo",
  [267] = "Destro",
  [268] = "BM",
  [269] = "WW",
  [270] = "MW",
}

-- Taken from http://wowprogramming.com/snippets/UTF-8_aware_stringsub_7.
local function charSize(byte)
  if byte > 240 then
    return 4
  elseif byte > 225 then
    return 3
  elseif byte > 192 then
    return 2
  else
    return 1
  end
end

local function containsMultiByteChar(string)
  for i = 1, _G.string.len(name) do
    if charSize(_G.string.byte(name, i)) > 1 then
      return true
    end
  end
  return false
end

-- Create an array of space-separated substrings and try to form a string with no more than 16
-- characters by replacing as few substrings as possible (preferring those with lower index) by
-- their initial character followed by a dot and concatenating.  If that approach fails, append
-- "..." to the name's first 9 characters.  See
-- http://www.wowhead.com/forums&topic=204361/lua-code-limit-name-characters
-- Significant events: UNIT_NAME_UPDATE, UNIT_TARGETABLE_CHANGED, UNIT_FACTION. One of those events
-- fires when the unit is tapped.
settings.nameTag = function(unit)
  local color = "ffffffff"
  if _G.UnitIsPlayer(unit) then
    local class = (_G.select(2, _G.UnitClassBase(unit)))
    color = class and settings.classColors[class].colorStr or "ffffffff"
  -- Similar to code from TargetFrame_CheckFaction() from Blizzard's TargetFrame.lua.  See
  -- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/TargetFrame.lua
  elseif not _G.UnitPlayerControlled(unit) and _G.UnitIsTapped(unit) and not
    _G.UnitIsTappedByPlayer(unit) and not _G.UnitIsTappedByAllThreatList(unit) then
    color = settings.tappedColor
  end

  local name = (_G.UnitName(unit))
  --local name = _G.GetUnitName(unit)
  if not name or name == "" then
    return settings.unknownName
  end

  -- Don't abbreviate player names. Don't abbreviate strings containing multi-byte Unicode
  -- characters, because the Lua string library is not aware of their existance.
  -- Pets names can contain multi-byte characters, and appear to be allowed to be at least 16
  -- characters long.
  -- TODO: abbreviate strings with multi-byte characters by appending "..." to the first 13
  -- characters.

  -- We have to check both these functions because UnitIsPlayer() returns 1 for some NPCs (e.g.
  -- Sikari the Mistweaver).
  if _G.UnitPlayerControlled(unit) and _G.UnitIsPlayer(unit) then
    if (_G.select(2, _G.GetInstanceInfo())) == "arena" then
      for i = 1, _G.GetNumArenaOpponents() do
        if _G.UnitIsUnit(unit, "arena" .. i) then
          return "[" .. i .. "] |c" .. color .. name .. "|r"
        end
      end
    else
      return "|c" .. color .. name .. "|r"
    end
  elseif not containsMultiByteChar(name) then
    local length = _G.string.len(name)
    if length <= 16 then return "|c" .. color .. name .. "|r" end
    local surplus = length - 16
    local i = 1
    local words = {}
    for word in _G.string.gmatch(name, "%S+") do
      words[i] = word
      i = i + 1
    end
    for k, v in _G.ipairs(words) do
      if (_G.string.len(v)) - 2 >= surplus then
        words[k] = _G.string.sub(v, 1, 1) .. "."
        name = words[1]
        for i = 2, #words do
          name = name .. " " .. words[i]
        end
        return "|c" .. color .. name .. "|r"
      end
    end
    for i = 1, #words do
      for j = i + 1, #words do
        if (words[i]:len() + words[j]:len()) - 4 >= surplus then
          words[i] = words[i]:sub(1, 1) .. "."
          words[j] = words[j]:sub(1, 1) .. "."
          name = words[1]
          for i = 2, #words do
            name = name .. " " .. words[i]
          end
          return "|c" .. color .. name .. "|r"
        end
      end
    end
    return "|c" .. color .. _G.string.sub(name, 1, 9) .. "..." .. "|r"
  else
    return "|c" .. color .. name .. "|r"
  end
end

--------------------------------------------------------------------------------------------------
-- http://www.wowace.com/addons/librangecheck-2-0/pages/api/
-- http://www.wowace.com/addons/libstub/

settings.rangeChecker = _G.LibStub:GetLibrary("LibRangeCheck-2.0"--[[, true]])
--[[
-- The second argument tells LibStub to not raise an error if the library is not found. We will
-- wait to see if LibRangeCheck-2.0 is loaded and try again.
if not settings.rangeChecker then
  local f = _G.CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, name)
    if name == "LibRangeCheck-2.0" then
      self:UnregisterEvent("ADDON_LOADED")
        settings.rangeChecker = _G.LibStub:GetLibrary("LibRangeCheck-2.0")
      self.ADDON_LOADED = nil
    end
  end)
  f:RegisterEvent("ADDON_LOADED")
end
]]

settings.rangeTag = function(unit)
  if not _G.UnitIsConnected(unit) then return end

  local color
  if _G.UnitIsUnit(unit .. "target", "player") then
    color = "ffe00000"
  else
    color = "ffffffff"
  end

  local minRange, maxRange = settings.rangeChecker:GetRange(unit)
  local ranges = nil

  if minRange and not maxRange then
    ranges = minRange .. "+"
  elseif minRange and maxRange then
    ranges = minRange .. "-" .. maxRange
  end
  return "|c" .. color .. ranges .. "|r"
end
--------------------------------------------------------------------------------------------------

-- I use this tag as a poor man's version of the spec tag outside of Arena because some information
-- about a players spec can be inferred from her maximum power.  For example, Assassination Rogues
-- will have extra energy, Prot and Ret Palas (similarly: Druids) will have less mana (60k at level
-- 90), etc.  It may be worth considering to always show the maximum mana when the unit is a druid.
-- Significant events: UNIT_MAXPOWER UNIT_DISPLAYPOWER ARENA_PREP_OPPONENT_SPECIALIZATIONS
-- ROLE_CHANGED_INFORM
settings.powerMaxTag = function(unit)
  if not _G.UnitIsConnected(unit) then return end

  if (_G.select(2, _G.GetInstanceInfo())) == "arena" then
    for i = 1, _G.GetNumArenaOpponents() do
      if _G.UnitIsUnit(unit, "arena" .. i) then
        local specId = _G.GetArenaOpponentSpec(i)
        if specId then
          return settings.specNames[specId]
        end
      end
    end
  end

  local role = _G.UnitGroupRolesAssigned(unit)
  if role and role ~= "NONE" and role ~= "DAMAGER" then
    return settings.roles[role]
  end

  local powerType, powerToken, altR, altG, altB
  if _G.UnitIsPlayer(unit) and _G.select(2, _G.UnitClassBase(unit)) == "DRUID" then
    -- If it's a druid, show maximum mana.
    powerType, powerToken = _G.SPELL_POWER_MANA, "MANA"
  else
    powerType, powerToken, altR, altG, altB = _G.UnitPowerType(unit)
  end

  local powerMax = powerType and _G.UnitPowerMax(unit, powerType) or _G.UnitPowerMax(unit)
  if not powerMax or powerMax == 0 then return end

  local colorStr
  if powerToken and settings.powerColors[powerToken] then
    colorStr = settings.powerColors[powerToken].colorStr
  elseif altR and altG and altB then
    colorStr = _G.string.format("ff%02x%02x%02x", altR * 255, altG * 255, altB * 255)
  else
    colorStr = "ffffffff"
  end

  local powerMaxStr = ""
  if powerType and powerType == _G.SPELL_POWER_MANA then
    powerMaxStr = _G.string.format("%dk", _G.math.floor((powerMax + 500) / 1000))
  else
    powerMaxStr = _G.string.format("%d", powerMax)
  end

  return "|c" .. colorStr .. powerMaxStr .. "|r"
end

frameAttributes = {}

_G.table.insert(frameAttributes, {
  name = "NKPlayerFrame",
  unit = "player",
  create = createUnitFrame,

  point         = "BOTTOMLEFT",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOMLEFT",
  xOffset       = 467,
  yOffset       = 348,
  width         = settings.defaults.width,

  bars = {
    {
      create = createManaBar,
      height = 2,
    },
    {
      create = createHealthBar,
      height = 21,
      mirror = true,
    },
  },
})

_G.table.insert(frameAttributes, {
  name = "NKVehicleFrame",
  unit = "vehicle",
  create = createUnitFrame,

  point         = "BOTTOMRIGHT",
  relativeTo    = "NKPlayerFrame",
  relativePoint = "BOTTOMLEFT",
  xOffset       = -8,
  yOffset       = 0,
  width         = settings.defaults.width,

  bars = {
    {
      create = createPowerBar,
      height = 2,
    },
    {
      create = createHealthBar,
      height = 21,
      mirror = true,
    },
  },
})

for i = 1, 4 do
  _G.table.insert(frameAttributes, {
    name = "NKParty" .. i .. "Frame",
    unit = "party" .. i,
    create = createUnitFrame,

    point         = "TOP",
    relativeTo    = (i == 1) and "NKPlayerFrame" or ("NKParty" .. (i - 1) .. "Frame"),
    relativePoint = "BOTTOM",
    xOffset       = 0,
    -- 2 + 28 + 8 = 38. 1 + 21 + 1 + 2 + 1 + 21 + 1 + 2 + 28 + 8 = 86
    yOffset       = -38--[[ - 86 * (i - 1)]],
    width         = settings.defaults.width,

    bars = {
      {
        create = createHeaderBar,
        height = 21,
        mirror = true,
      },
      {
        create = createPowerBar,
        height = 2,
      },
      {
        create = createHealthBar,
        height = 8,
        mirror = true,
      },
    },
  })
end

_G.table.insert(frameAttributes, {
  name = "NKKittyPowerFrame",
  create = createKittyPowerFrame,

  point         = "BOTTOM",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = 328,
  width         = 170,
  height        = 4,
})

_G.table.insert(frameAttributes, {
  name = "NKPlayerPowerBarAlt",
  unit = "player",
  create = createAltPowerFrame,

  point         = "BOTTOM",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = 368,
  width         = 170,
  height        = 4,
})

_G.table.insert(frameAttributes, {
  name = "NKTargetFrame",
  unit = "target",
  create = createUnitFrame,

  point         = "BOTTOMRIGHT",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOMRIGHT",
  xOffset       = -467,
  yOffset       = 348,
  width         = settings.defaults.width,

  bars = {
    {
      barType = "Header",
      attributes = {

      },
      create = createHeaderBar,
      height = 21,
      tags = {
        {
          proportion = 1,
        },
        {
          proportion = 1,
        },
        {
          tagType = RangeTag,
          proportion = 1,
        },
      },
    },
    {
      create = createPowerBar,
      height = 2,
      mirror = true,
    },
    {
      create = createHealthBar,
      height = 21,
    },
  },
})

_G.table.insert(frameAttributes, {
  name = "NKFocusFrame",
  unit = "focus",
  create = createUnitFrame,

  point         = "TOP",
  relativeTo    = "NKTargetFrame",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = -38, -- 2 + 28 + 8 = 38
  width         = settings.defaults.width,

  bars = {
    {
      create = createHeaderBar,
      height = 21,
    },
    {
      create = createPowerBar,
      height = 2,
      mirror = true,
    },
    {
      create = createHealthBar,
      height = 8,
    },
  },
})

_G.table.insert(frameAttributes, {
  name = "NKPlayerCastFrame",
  unit = "player",
  create = createCastFrame,

  point         = "BOTTOM",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = 368--[[262]],
  width         = 170--[[236]],
  height        = 6,
})

_G.table.insert(frameAttributes, {
  name = "NKTargetCastFrame",
  unit = "target",
  create = createCastFrame,

  point         = "TOPRIGHT",
  relativeTo    = "UIParent",
  relativePoint = "CENTER",
  xOffset       = 112, -- (193 - 1 + 32) / 2 = 112
  yOffset       = -34,
  width         = 193,
  height        = 23,

  icon = {
    point         = "BOTTOMRIGHT",
    relativePoint = "BOTTOMLEFT",
    xOffset       = 1,
    yOffset       = 0,
  },
})

_G.table.insert(frameAttributes, {
  name = "NKFocusCastFrame",
  unit = "focus",
  create = createCastFrame,

  point         = "TOPLEFT",
  relativeTo    = "NKTargetCastFrame",
  relativePoint = "TOPRIGHT",
  xOffset       = 33,
  yOffset       = 0,
  width         = 193,
  height        = 23,

  icon = {
    point         = "BOTTOMRIGHT",
    relativePoint = "BOTTOMLEFT",
    xOffset       = 1,
    yOffset       = 0,
  },
})

for i = 1, 3 do
  _G.table.insert(frameAttributes, {
    name = "NKArena" .. i .. "Frame",
    unit = "arena" .. i,
    create = createUnitFrame,

    point         = "TOP",
    relativeTo    = (i == 1) and "NKFocusFrame" or ("NKArena" .. (i - 1) .. "Frame"),
    relativePoint = "BOTTOM",
    xOffset       = 0,
    yOffset       = -38--[[ - (i - 1) * 69]], -- 2 + 28 + 8 + (i- 1) * 1 + 21 + 1 + 2 + 1 + 4 + 1 + 2 + 28 + 8
    width         = settings.defaults.width,

    bars = {
      {
        create = createHeaderBar,
        height = 21,
      },
      {
        create = createPowerBar,
        height = 2,
        mirror = true,
      },
      {
        create = createHealthBar,
        height = 8,
      },
    },
  })
end

-- vim: tw=100 sw=2 et
