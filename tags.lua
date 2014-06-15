setfenv(1, NinjaKittyUF)

-- Prototype.
NameTag = {
  tags = {},
}

do
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
  -- http://www.wowhead.com/forums&topic=204361/lua-code-limit-name-characters Significant events:
  -- UNIT_NAME_UPDATE, UNIT_TARGETABLE_CHANGED, UNIT_FACTION. One of those events fires when the
  -- unit is tapped.
  function NameTag:getNameText()
    local unit = self.unit
    local color = "ffffffff"
    if not _G.UnitExists(unit) and (_G.select(2, _G.IsInInstance())) == "arena" then
      local specID
      --for i = 1, _G.MAX_ARENA_ENEMIES do
      for i = 1, _G.GetNumArenaOpponentSpecs() do
        if unit == "arena" .. i then
          specID = _G.GetArenaOpponentSpec(i)
          break
        end
      end
      if specID and specID > 0 then
        _, _, _, _, _, _, class = _G.GetSpecializationInfoByID(specID)
        color = class and settings.classColors[class].colorStr or "ffffffff"
      end
    elseif _G.UnitIsPlayer(unit) then
      local class = (_G.select(2, _G.UnitClassBase(unit)))
      color = class and settings.classColors[class].colorStr or "ffffffff"
    -- Similar to code from TargetFrame_CheckFaction() from Blizzard's TargetFrame.lua.  See
    -- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/TargetFrame.lua
    elseif not _G.UnitPlayerControlled(unit) and _G.UnitIsTapped(unit) and not
    _G.UnitIsTappedByPlayer(unit) and not _G.UnitIsTappedByAllThreatList(unit) and not
    _G.UnitIsDead(unit) then
      color = settings.colors.tapped.colorStr
    end

    local name = (_G.UnitName(unit))
    --local name = _G.GetUnitName(unit)
    if not name or name == "" then
      return "|c" .. color .. settings.strings.unknown .. "|r"
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
      --[[
      if (_G.select(2, _G.GetInstanceInfo())) == "arena" then
        for i = 1, _G.GetNumArenaOpponents() do
          if _G.UnitIsUnit(unit, "arena" .. i) then
            return "[" .. i .. "] |c" .. color .. name .. "|r"
          end
        end
      end
      ]]
      return "|c" .. color .. name .. "|r"
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

  function NameTag:new(unit, callback) -- Constructor.
    local object = _G.setmetatable({}, { __index = self })
    object.unit = unit
    object.callback = callback
    object.text = ""
    return object
  end

  function NameTag:enable()
    self.tags[self.unit] = self
    self:update()
  end

  function NameTag:disable()
    self.tags[self.unit] = nil
  end

  function NameTag:update()
    self.text = self:getNameText()
    self.callback(self.text)
  end

  local f = _G.CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function f:UNIT_NAME_UPDATE(unit)
    local tag = NameTag.tags[unit]
    if not tag then return end
    tag:update()
  end

  function f:UNIT_TARGETABLE_CHANGED(unit)
    local tag = NameTag.tags[unit]
    if not tag then return end
    tag:update()
  end

  function f:UNIT_FACTION(unit)
    local tag = NameTag.tags[unit]
    if not tag then return end
    tag:update()
  end

  f:RegisterEvent("UNIT_NAME_UPDATE")
  f:RegisterEvent("UNIT_TARGETABLE_CHANGED")
  f:RegisterEvent("UNIT_FACTION")
end

-- Prototype.
ArenaIDTag = {
  tags = {},
}

do
  local function getArenaID(unit)
    if (_G.select(2, _G.GetInstanceInfo())) == "arena" then
      --if _G.UnitPlayerControlled(unit) and _G.UnitIsPlayer(unit) then
        --for i = 1, _G.GetNumArenaOpponents() do
        for i = 1, _G.GetNumArenaOpponentSpecs() do
        --for i = 1, _G.MAX_ARENA_ENEMIES do
          --if _G.UnitIsUnit(unit, "arena" .. i) then
          if unit == "arena" .. i then
            return _G.tostring(i)
          end
        --end
      end
    else
      return nil
    end
  end

  function ArenaIDTag:new(unit, callback) -- Constructor.
    local object = _G.setmetatable({}, { __index = self })
    object.unit = unit
    object.callback = callback
    object.text = ""
    return object
  end

  function ArenaIDTag:enable()
    self.tags[self.unit] = self
    self:update()
  end

  function ArenaIDTag:disable()
    self.tags[self.unit] = nil
  end

  function ArenaIDTag:update()
    self.text = getArenaID(self.unit)
    self.callback(self.text)
  end
end

-- Prototype.
RangeTag = {
  activeTags = {},
  idleTags = {},
}

do
  -- http://www.wowace.com/addons/libstub
  -- http://www.wowace.com/addons/librangecheck-2-0/pages/api
  local rangeChecker = _G.LibStub:GetLibrary("LibRangeCheck-2.0")

  local function getRangeText(unit)
    local minRange, maxRange = rangeChecker:GetRange(unit)

    if not minRange then
      return ""
    elseif minRange and not maxRange then
      return minRange .. "+"
    elseif minRange and maxRange then
      return minRange .. "-" .. maxRange
    end
  end

  function RangeTag:new(unit, callback) -- Constructor.
    local object = _G.setmetatable({}, { __index = self })
    object.unit = unit
    object.callback = callback
    object.color = "ffffffff"
    object.text = nil
    return object
  end

  function RangeTag:update()
    self:disable()
    if not _G.UnitExists(self.unit) then
      return
    elseif _G.UnitIsConnected(self.unit) then
      RangeTag.activeTags[self.unit] = self
      local color
      if _G.UnitIsUnit(self.unit .. "target", "player") then
        color = "ffe00000"
      else
        color = "ffffffff"
      end
      local rangeText = getRangeText(self.unit)
      if color ~= self.color or rangeText ~= self.text then
        self.color = color
        self.text = rangeText
        self.callback("|c" .. self.color .. self.text .. "|r")
      end
    else
      RangeTag.idleTags[self.unit] = self
      if self.text ~= "Offline" or self.color ~= "ffffffff" then
          self.text = "Offline"
          self.color = "ffffffff"
          self.callback("|c" .. self.color .. self.text .. "|r")
      end
    end
  end

  function RangeTag:disable()
    self.text = "0+"
    self.color = "ffffffff"
    self.callback("|c" .. self.color .. self.text .. "|r")
    RangeTag.activeTags[self.unit] = nil
    RangeTag.idleTags[self.unit] = nil
  end

  function RangeTag:enable()
    self:disable()
    if _G.UnitExists(self.unit) and _G.UnitIsConnected(self.unit) then
      RangeTag.activeTags[self.unit] = self
    else
      RangeTag.idleTags[self.unit] = self
    end
    self:update()
  end

  function RangeTag:onUpdate()
    for unit, tag in _G.pairs(RangeTag.activeTags) do
      local rangeText = getRangeText(unit)
      if rangeText ~= tag.text then
        tag.text = rangeText
        tag.callback("|c" .. tag.color .. tag.text .. "|r")
      end
    end
  end

  local frame = _G.CreateFrame("Frame")
  frame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  frame:SetScript("OnUpdate", function(self, elapsed) return RangeTag:onUpdate() end)

  function frame:PLAYER_TARGET_CHANGED(cause)
    for unit, tag in _G.pairs(RangeTag.activeTags) do
      if _G.UnitExists(unit) and _G.UnitIsUnit(unit, "player") then
        local color
        if _G.UnitIsUnit(unit .. "target", "player") then
          color = "ffe00000"
        else
          color = "ffffffff"
        end
        local rangeText = getRangeText(unit)
        if color ~= tag.color or rangeText ~= tag.text then
          tag.color = color
          tag.text = rangeText
          tag.callback("|c" .. tag.color .. tag.text .. "|r")
        end
      end
    end
  end

  function frame:UNIT_TARGET(unit, cause)
    local tag = RangeTag.activeTags[unit]
    if not tag or _G.UnitIsUnit(unit, "player") then return end

    local color
    if _G.UnitIsUnit(unit .. "target", "player") then
      color = "ffe00000"
    else
      color = "ffffffff"
    end
    local rangeText = getRangeText(unit)
    if color ~= tag.color or rangeText ~= tag.text then
      tag.color = color
      tag.text = rangeText
      tag.callback("|c" .. tag.color .. tag.text .. "|r")
    end
  end

  function frame:UNIT_CONNECTION(unit, hasConnected)
    local tag = RangeTag.activeTags[unit] --[[or RangeTag.idleTags[unit]--]]
    if not tag then return end
    tag:update()
  end

  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("UNIT_TARGET")
  frame:RegisterEvent("UNIT_CONNECTION")
end

-- Prototype.
SpecTag = {
  tags = {},
}

do
  function SpecTag:new(unit, callback) -- Constructor.
    local object = _G.setmetatable({}, { __index = self })
    object.unit = unit
    object.callback = callback
    object.text = ""
    return object
  end

  function SpecTag:enable()
    self.tags[self.unit] = self
    self:update()
  end

  function SpecTag:disable()
    self.tags[self.unit] = nil
  end

  -- http://wowprogramming.com/docs/api_types#specID
  local specNames = {
    [62] = "Arcane", [63] = "Fire", [64] = "Frost", -- Mage
    [65] = "Holy", [66] = "Prot", [70] = "Ret", -- Paladin
    [71] = "Arms", [72] = "Fury", [73] = "Prot", -- Warrior
    [102] = "Balance", [103] = "Feral", [104] = "Guardian", [105] = "Resto", -- Druid
    [250] = "Blood", [251] = "Frost", [252] = "Unh", -- Death Knight
    [253] = "BM", [254] = "MM", [255] = "Surv", -- Hunter
    [256] = "Disc", [257] = "Holy", [258] = "Shadow", -- Priest
    [259] = "Ass", [260] = "Combat", [261] = "Sub", -- Rogue
    [262] = "Ele", [263] = "Enh", [264] = "Resto", -- Shaman
    [265] = "Aff", [266] = "Demo", [267] = "Destro", -- Warlock
    [268] = "BM", [269] = "WW", [270] = "MW", -- Monk
  }

  -- Used to get abbreviated spec names from GetBattlefieldScore() which only returns localized spec
  -- names.
  local specIDs = {
    ["Arcane"] = 62, ["Fire"] = 63, ["Frost"] = 64,
    ["Holy"] = 65, ["Protection"] = 66, ["Retribution"] = 70,
    ["Arms"] = 71, ["Fury"] = 72, --[[["Protection"] = 73,]]
    ["Balance"] = 102, ["Feral"] = 103, ["Guardian"] = 104, ["Restoration"] = 105,
    ["Blood"] = 250, --[[["Frost"] = 251,]] ["Unholy"] = 252,
    ["Beast Mastery"] = 253, ["Marksmanship"] = 254, ["Survival"] = 255,
    ["Discipline"] = 256, --[[["Holy"] = 257,]] ["Shadow"] = 258,
    ["Assassination"] = 259, ["Combat"] = 260, ["Subtlety"] = 261,
    ["Elemental"] = 262, ["Enhancement"] = 263, --[[["Restoration"] = 264,]]
    ["Affliction"] = 265, ["Demonology"] = 266, ["Destruction"] = 267,
    ["Brewmaster"] = 268, ["Windwalker"] = 269, ["Mistweaver"] = 270, }

  local roleNames = {
    ["DAMAGER"] = "DPS",
    ["HEALER"] = "Healer",
    ["TANK"] = "Tank",
  }

  local pendingScoreDataRequests = 0

  local battlegroundSpecs = {}

  -- Shows the first available:
  -- 1. specialization (in arena and battlegrounds)
  -- 2. role, (only tank or healer)
  -- 3. maximum power (always maximum mana for druids)
  --
  -- We use role and maximum power as a poor man's version of the spec tag because some information
  -- about a players spec can be inferred from the maximum power.  For example, Assassination Rogues
  -- will have extra energy, Prot and Ret Palas (similarly: Druids) will have low mana (60k at level
  -- 90), etc.  Significant events: UNIT_MAXPOWER UNIT_DISPLAYPOWER
  -- ARENA_PREP_OPPONENT_SPECIALIZATIONS ROLE_CHANGED_INFORM
  local function getSpecText(tag)
    local unit = tag.unit
    local instanceType = (_G.select(2, _G.IsInInstance()))

    if instanceType == "arena" then
      local numOpps = _G.GetNumArenaOpponentSpecs()
      local specId
      for i = 1, numOpps do
        if _G.UnitIsUnit(unit, "arena" .. i) then
          specId = _G.GetArenaOpponentSpec(i)
          break
        end
      end
      if specId then
        return specNames[specId]
      end
    end

    if not _G.UnitExists(unit) or not _G.UnitIsConnected(unit) then return end

    if instanceType == "pvp" then
      local spec = battlegroundSpecs[_G.GetUnitName(unit, true)]
      if spec then
        return specNames[specIDs[spec]]
      else
        _G.RequestBattlefieldScoreData()
        pendingScoreDataRequests = pendingScoreDataRequests + 1
      end
    end

    if tag.role and tag.role ~= "NONE" and tag.role ~= "DAMAGER" then
      return roleNames[tag.role]
    end

    local powerType, powerToken, altR, altG, altB
    if _G.UnitIsPlayer(unit) and _G.select(2, _G.UnitClassBase(unit)) == "DRUID" then
      powerType, powerToken = _G.SPELL_POWER_MANA, "MANA" -- If it's a druid, show maximum mana.
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

  function SpecTag:update()
    self.role = _G.UnitGroupRolesAssigned(self.unit)
    self.text = getSpecText(self)
    self.callback(self.text)
  end

  local f = _G.CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function f:UNIT_MAXPOWER(unit)
    local tag = SpecTag.tags[unit]
    if not tag then return end
    tag:update()
  end

  -- From http://wowprogramming.com/docs/events/ROLE_CHANGED_INFORM: "[u]se the additional arguments
  -- if you want to immediately use the new status; a call to UnitGroupRolesAssigned may not report
  -- the new data when called at this time."
  function f:ROLE_CHANGED_INFORM(changedPlayer, changedBy, oldRole, newRole)
    -- changedPlayer is the name of the unit whose role has changed. UnitIsUnit() does accept unit
    -- names. See http://wowprogramming.com/docs/api_types#unitID
    for unit, tag in _G.pairs(SpecTag.tags) do
      if _G.UnitIsUnit(unit, changedPlayer) then
        tag.role = newRole
        tag.text = getSpecText(tag)
        tag.callback(tag.text)
      end
    end
  end

  function f:ARENA_PREP_OPPONENT_SPECIALIZATIONS(...)
    for _, tag in _G.pairs(SpecTag.tags) do
      tag:update()
    end
  end

  -- We have to call RequestBattlefieldScoreData() to get score data from the server.  The
  -- UPDATE_BATTLEFIELD_SCORE event fires once information is available and can be retrieved by
  -- calling GetBattlefieldScore() and related functions.
  function f:UPDATE_BATTLEFIELD_SCORE()
    if pendingScoreDataRequests <= 0 then return end

    pendingScoreDataRequests = pendingScoreDataRequests - 1
    local numScores = _G.GetNumBattlefieldScores() -- Returns 0 if not in a battleground.
    for i = 1, numScores do
      local name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = _G.GetBattlefieldScore(i)
      battlegroundSpecs[name] = talentSpec
    end
    for unit, tag in _G.pairs(SpecTag.tags) do
      local text = getSpecText(tag)
      if text ~= tag.text then
        tag.text = text
        tag.callback(text)
      end
    end
  end

  f:RegisterEvent("UNIT_MAXPOWER")
  f:RegisterEvent("ROLE_CHANGED_INFORM")
  f:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
  f:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
end

--[==[
function registerTag(tagGroup, unit, callback)
  return tagGroup.registerUnit(unit, callback)
end

tagGroups = {}

do
  tagGroups.kittyPower = {
    registerUnit = function(unit, callback)
      tagGroups.kittyPower.tags[unit] = {
        callback = callback,
      }
    end,
    unregisterUnit = function(unit)
      tagGroups.kittyPower.tags[unit] = nil
    end,
    tags = {},
  }

  getKittyPowerText = function(unit)
    if not _G.UnitIsConnected(unit) then return end

    local colorStr, powerStr
    local powerType = _G.UnitPowerType(unit)

    if powerType == _G.SPELL_POWER_RAGE then
      colorStr = settings.powerColors["RAGE"].colorStr
      powerStr = _G.UnitPower(unit, _G.SPELL_POWER_RAGE)
    else
      colorStr = settings.powerColors["ENERGY"].colorStr
      powerStr = _G.UnitPower(unit, _G.SPELL_POWER_ENERGY)
    end

    return "|c" .. colorStr .. powerStr .. "|r"
  end
end
--]==]

--[==[
do
  tagGroups.health = {
    registerUnit = function(unit, callback)
      tagGroups.health.tags[unit] = {
        callback = callback,
        text = "",
      }
    end,
    unregisterUnit = function(unit)
      tagGroups.health.tags[unit] = nil
    end,
    tags = {},
  }

  local tagGroup = tagGroups.health

  getHealthText = function(unit, healthMax, health, totalAbsorbs)
    if not _G.UnitIsConnected(unit) then
      return "|c" .. settings.offlineColor .. settings.strings.offline .. "|r"
    end

    local healthStr

    local colorStr
    if --[[_G.UnitIsPlayer(unit)]] true then
      -- I don't like the blue UnitSelectionColor() returns when the unit is a player not active for
      -- PvP in some places. It's also used for NPCs sometimes.
      if _G.UnitIsEnemy("player", unit) then
        if _G.UnitCanAttack(unit, "player") then -- He can attack us. Red.
          colorStr = "ffff0000"
        else -- He can't attack us. Yellow.
          colorStr = "ffffff00"
        end
      else -- He's our friend. Green.
        colorStr = "ff00ff00"
      end
    else
      local red, green, blue, alpha = _G.UnitSelectionColor(unit)
      -- http://wowprogramming.com/docs/api_types#colorString
      colorStr = _G.string.format("%02x%02x%02x%02x", alpha * 255, red * 255, green * 255, blue *
        255)
    end

    if _G.UnitIsDead(unit) then
      healthStr = settings.strings.dead
    elseif _G.UnitIsGhost(unit) then
      healthStr = settings.strings.ghost
    else
      if healthMax / 1000 >= 10000 then
        healthStr = _G.string.format("%dm", _G.math.floor((health + 500000) / 1000000))
      else
        healthStr = _G.string.format("%dk", _G.math.floor((health + 500) / 1000))
      end
      if totalAbsorbs / 1000 >= 10000 then
        healthStr = healthStr .. " + " .. _G.string.format("%dm", _G.math.floor((totalAbsorbs +
          500000) / 1000000))
      elseif totalAbsorbs > 0 then
        healthStr = healthStr .. " + " .. _G.string.format("%dk", _G.math.floor((totalAbsorbs + 500)
          / 1000))
      end
    end

    return "|c" .. colorStr .. healthStr .. "|r"
  end

  tagGroup.update = function(unit)
    local tag = tagGroup.tags[unit]
    tag.text = getHealthText(unit)
    tag.callback(tag.text)
  end

  tagGroup.reset = function(unit)
    local tag = tagGroup.tags[unit]
    tag.callback(tag.text)
  end

  local f = _G.CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function f:UNIT_HEALTH_FREQUENT(unit)
    if not tagGroup.tags[unit] then return end
    tagGroup.update(unit)
  end

  function f:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unit)
    if not tagGroup.tags[unit] then return end
    tagGroup.update(unit)
  end

  function f:UNIT_CONNECTION(unit)
    if not tagGroup.tags[unit] then return end
    tagGroup.update(unit)
  end

  function f:UNIT_FACTION(unit)
    if not tagGroup.tags[unit] then return end
    tagGroup.update(unit)
  end
end
--]==]

-- vim: tw=100 sw=2 ts=2 et
