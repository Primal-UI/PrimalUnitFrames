local addonName, addon = ...

setfenv(1, addon)

settings = {
  epsilon = 0.001,
  spacing = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
  fontSpacing = 2,
  classColors = _G.RAID_CLASS_COLORS,
  barTexture = [[Interface\AddOns\]] .. addonName ..  [[\media\textures\plain_white]],
  defaultFont = _G.CreateFont("NKUFDefaultFont"),
  fontSize = 11,
  strings = {
    dead    = "Dead",
    ghost   = "Ghost",
    offline = "Offline",
    unknown = "Unknown",
  },
  colors = {
    background = { r = 0, g = 0, b = 0, a = .5, colorStr = "80000000" },
    casting = { r = .85, g = .25, b = .25, a = .75, colorStr = "bfd94040" },
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
  defaults = {
    width = 208,
  },
  roles = {
    ["DAMAGER"] = "DPS",
    ["HEALER"] = "Healer",
    ["TANK"] = "Tank",
  },
}

------------------------------------------------------------------------------------------------------------------------
-- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitFrame.lua
-- http://forums.wowace.com/showthread.php?t=18724
settings.powerColors = {}
for powerToken, color in _G.pairs(_G.PowerBarColor) do
  if color.r and color.g and color.b then
    settings.powerColors[powerToken] = { r = color.r, g = color.g, b = color.b, a = settings.powerAlpha }
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

settings.defaultFont:SetFont([[Interface\AddOns\PrimalMedia\fonts\Ubuntu-M.ttf]], 11, "")
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
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
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

frameAttributes = {}

_G.table.insert(frameAttributes, {
  name = "NKPlayerFrame",
  unit = "player",
  create = createUnitFrame,

  width = settings.defaults.width,

  point         = "TOPLEFT",
  relativeTo    = "UIParent",
  relativePoint = "LEFT",
  xOffset       = 467,
  yOffset       = -32,

  bars = {
    --[[
    {
      create = createManaBar,
      height = 2,
    },
    --]]
    {
      create = createHealthBar,
      height = 20,
      mirror = true,
    },
    ----[[
    {
      create = createManaBar,
      height = 2,
    },
    {
      create = createHealthBar,
      height = 6,
      mirror = true,
    },
    --]]
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
      create = createHealthBar,
      height = 20,
      mirror = true,
    },
    {
      create = createPowerBar,
      height = 2,
    },
    {
      create = createHealthBar,
      height = 6,
      mirror = true,
    },
  },
})

for i = 1, 4 do
  _G.table.insert(frameAttributes, {
    name = "NKParty" .. i .. "Frame",
    unit = "party" .. i,
    create = createUnitFrame,

    width         = settings.defaults.width,

    point         = "TOP",
    relativeTo    = (i == 1) and "NKPlayerFrame" or ("NKParty" .. (i - 1) .. "Frame"),
    relativePoint = "BOTTOM",
    xOffset       = 0,
    --yOffset       = -38,
    yOffset       = -60,

    bars = {
      {
        create = createHeaderBar,
        height = 20,
        mirror = true,
      },
      {
        create = createPowerBar,
        height = 2,
      },
      {
        create = createHealthBar,
        height = 6,
        mirror = true,
      },
    },
  })
end

--[[
_G.table.insert(frameAttributes, {
  name = "NKParty1CastFrame",
  unit = "party1",
  create = createCastFrame,

  parent = "NKParty1Frame",

  point         = "BOTTOMLEFT",
  relativeTo    = "NKParty1Frame",
  relativePoint = "TOPLEFT",
  xOffset       = -2,
  yOffset       = 2,

  width         = settings.defaults.width + 2,
  height        = 22,

  icon = {
    point         = "BOTTOMLEFT",
    relativePoint = "BOTTOMRIGHT",
    xOffset       = -1,
    yOffset       = 0,
  },
})
]]

--[[
_G.table.insert(frameAttributes, {
  name = "PUFTargetHealth",
  unit = "target",
  create = createUnitFrame,

  point         = "BOTTOM",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = 368,
  width         = 168,
  height        = 4,

  bars = {
    {
      create = createHealthBar,
      height = 2,
    },
  },
})
]]

_G.table.insert(frameAttributes, {
  name = "NKKittyPowerFrame",
  create = createKittyPowerFrame,

  point         = "BOTTOM",
  relativeTo    = "UIParent",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = 328,
  width         = 168,
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
  width         = 168,
  height        = 4,
})

_G.table.insert(frameAttributes, {
  name = "NKTargetFrame",
  unit = "target",
  create = createUnitFrame,

  width = settings.defaults.width,

  point         = "BOTTOMLEFT",
  relativeTo    = "NKPlayerFrame",
  relativePoint = "BOTTOMRIGHT",
  xOffset       = 1920 - 2 * 467 - 2 * settings.defaults.width,
  yOffset       = 0,

  bars = {
    {
      barType = "Header",
      attributes = {

      },
      create = createHeaderBar,
      height = 20,
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
      height = 20,
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
  yOffset       = -60, -- 2 + 28 + 8 + 22 = 60
  width         = settings.defaults.width,

  bars = {
    {
      create = createHeaderBar,
      height = 20,
    },
    {
      create = createPowerBar,
      height = 2,
      mirror = true,
    },
    {
      create = createHealthBar,
      height = 6,
    },
  },
})

_G.table.insert(frameAttributes, {
  name = "NKFocusCastFrame",
  unit = "focus",
  create = createCastFrame,

  point         = "BOTTOMLEFT",
  relativeTo    = "NKFocusFrame",
  relativePoint = "TOPLEFT",
  xOffset       = -2,
  yOffset       = 2,

  width         = settings.defaults.width + 2,
  height        = 22,

  icon = {
    point         = "BOTTOMRIGHT",
    relativePoint = "BOTTOMLEFT",
    xOffset       = 1,
    yOffset       = 0,
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
  --yOffset       = 368,
  yOffset       = 294,
  --width         = 168,
  width         = 236,
  height        = 4,
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

  height        = 22,

  icon = {
    point         = "BOTTOMRIGHT",
    relativePoint = "BOTTOMLEFT",
    xOffset       = 1,
    yOffset       = 0,
  },
})

_G.table.insert(frameAttributes, {
  name = "NKArena1Frame",
  unit = "arena1",
  create = createUnitFrame,

  point         = "TOP",
  relativeTo    = "NKFocusFrame",
  relativePoint = "BOTTOM",
  xOffset       = 0,
  yOffset       = -60,
  width         = settings.defaults.width,

  bars = {
    {
      create = createHeaderBar,
      height = 20,
    },
    {
      create = createPowerBar,
      height = 2,
      mirror = true,
    },
    {
      create = createHealthBar,
      height = 6,
    },
  },
})

for i = 2, 3 do
  _G.table.insert(frameAttributes, {
    name = "NKArena" .. i .. "Frame",
    unit = "arena" .. i,
    create = createUnitFrame,

    point         = "TOP",
    relativeTo    = "NKArena" .. (i - 1) .. "Frame",
    relativePoint = "BOTTOM",
    xOffset       = 0,
    yOffset       = -60,
    width         = settings.defaults.width,

    bars = {
      {
        create = createHeaderBar,
        height = 20,
      },
      {
        create = createPowerBar,
        height = 2,
        mirror = true,
      },
      {
        create = createHealthBar,
        height = 6,
      },
    },
  })
end

for i = 1, 3 do
  _G.table.insert(frameAttributes, {
    name = "NKArena" .. i .. "CastFrame",
    unit = "arena" ..i ,
    create = createCastFrame,

    parent = "NKArena" .. i .. "Frame",

    point         = "BOTTOMLEFT",
    relativeTo    = "NKArena" .. i .. "Frame",
    relativePoint = "TOPLEFT",
    xOffset       = -2,
    yOffset       = 2,

    width         = settings.defaults.width + 2,
    height        = 22,

    icon = {
      point         = "BOTTOMRIGHT",
      relativePoint = "BOTTOMLEFT",
      xOffset       = 1,
      yOffset       = 0,
    },
  })
end

_G.table.insert(frameAttributes, {
  name = "NKAltTargetFrame",
  unit = "target",
  create = createUnitFrame,

  point         = "BOTTOMLEFT",
  relativeTo    = "NKArena1Frame",
  relativePoint = "TOPLEFT",
  xOffset       = 0,
  yOffset       = 32, -- 2 + 22 + 8
  width         = settings.defaults.width,

  bars = {
    {
      create = createHealthBar,
      height = 20,
    },
  },

  disabled = true,
})

-- vim: tw=120 sts=2 sw=2 et
