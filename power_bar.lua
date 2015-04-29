local addonName, addon = ...

setfenv(1, addon)

function createPowerBar(unit, mirror)
  local powerBar = _G.CreateFrame("Frame")
  local frameLevel = powerBar:GetFrameLevel()

  powerBar.powerStatusBar = _G.CreateFrame("StatusBar", nil, powerBar)
  do
    local statusBar = powerBar.powerStatusBar
    statusBar:SetAllPoints()
    if mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    local color = settings.colors.noPower
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
  end

  powerBar.powerMissingStatusBar = _G.CreateFrame("StatusBar", nil, powerBar)
  do
    local statusBar = powerBar.powerMissingStatusBar
    statusBar:SetAllPoints()
    if not mirror then
    statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    local color = settings.colors.powerBarBackground
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(1)
  end

  --------------------------------------------------------------------------------------------------
  powerBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function powerBar:UNIT_DISPLAYPOWER(unit)
    local powerMax = _G.UnitPowerMax(unit)
    if powerMax and powerMax > 0 then
      local _, powerToken, altR, altG, altB = _G.UnitPowerType(unit)
      local color = powerToken and settings.powerColors[powerToken] or nil
      if color then
        self.powerStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
      else
        self.powerStatusBar:SetStatusBarColor(altR, altG, altB, settings.powerAlpha)
      end
      -- See http://wowprogramming.com/docs/api/UnitPowerType
    else
      local color = settings.colors.noPower
      self.powerStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    self:UNIT_MAXPOWER(unit)
    self:UNIT_POWER_FREQUENT(unit)
  end
  powerBar:RegisterUnitEvent("UNIT_DISPLAYPOWER", unit)

  function powerBar:UNIT_MAXPOWER(unit)
    local powerMax = _G.UnitPowerMax(unit)
    if powerMax and powerMax > 0 then
      self.powerStatusBar:SetMinMaxValues(0, powerMax)
      self.powerMissingStatusBar:SetMinMaxValues(0, powerMax)
    else
      self.powerStatusBar:SetMinMaxValues(0, 1)
      self.powerStatusBar:SetValue(1)
      self.powerMissingStatusBar:SetMinMaxValues(0, 1)
      self.powerMissingStatusBar:SetValue(0)
    end
  end
  powerBar:RegisterUnitEvent("UNIT_MAXPOWER", unit)

  function powerBar:UNIT_POWER_FREQUENT(unit)
    if _G.UnitPowerType(unit) then
      local powerMax = _G.UnitPowerMax(unit)
      if powerMax and powerMax ~= 0 then
        if _G.UnitIsDeadOrGhost(unit) then
          self.powerStatusBar:SetValue(0)
          self.powerMissingStatusBar:SetValue(powerMax)
        else
          local maxValue = _G.select(2, self.powerStatusBar:GetMinMaxValues())
          local power    = _G.UnitPower(unit)
          self.powerStatusBar:SetValue(power)
          self.powerMissingStatusBar:SetValue(maxValue - power)
        end
      end
    end
  end
  powerBar.UNIT_POWER = powerBar.UNIT_POWER_FREQUENT
  powerBar:RegisterUnitEvent("UNIT_POWER", unit)
  powerBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)

  function powerBar:update(unit)
    if _G.UnitExists(unit) and _G.UnitIsConnected(unit) then
        self:UNIT_DISPLAYPOWER(unit)
        self:UNIT_POWER_FREQUENT(unit)
    elseif (_G.select(2, _G.IsInInstance())) == "arena" then
      self.powerStatusBar:SetMinMaxValues(0, 1)
      self.powerMissingStatusBar:SetMinMaxValues(0, 1)
      local specID
      for i = 1, _G.MAX_ARENA_ENEMIES do
        if unit == "arena" .. i then
          specID = _G.GetArenaOpponentSpec(i)
          break
        end
      end
      if specID and specID > 0 then
        local powerToken = powerTokens[specID]
        local color = powerToken and settings.powerColors[powerToken] or nil
        if not color then
          color = settings.colors.noPower
        end
        self.powerStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
        if powerToken then
          if powerToken == "MANA" or powerToken == "FOCUS" or powerToken == "ENERGY" then
            self.powerStatusBar:SetValue(1)
            self.powerMissingStatusBar:SetValue(0)
          elseif powerToken == "RAGE" or powerToken == "RUNIC_POWER" then
            self.powerStatusBar:SetValue(0)
            self.powerMissingStatusBar:SetValue(1)
          end
        end
      end
    else
      local color = settings.colors.noPower
      self.powerStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
      self.powerStatusBar:SetMinMaxValues(0, 1)
      self.powerMissingStatusBar:SetMinMaxValues(0, 1)
      self.powerStatusBar:SetValue(0)
      self.powerMissingStatusBar:SetValue(1)
    end
  end

  function powerBar:UNIT_CONNECTION(unit, hasConnected)
    self:update(unit)
  end
  powerBar:RegisterUnitEvent("UNIT_CONNECTION", unit)
  --------------------------------------------------------------------------------------------------

  return powerBar
end

-- Only use for player.
function createManaBar(unit, mirror)
  local manaBar = _G.CreateFrame("Frame")
  local frameLevel = manaBar:GetFrameLevel()

  manaBar.manaStatusBar = _G.CreateFrame("StatusBar", nil, manaBar)
  do
    local statusBar = manaBar.manaStatusBar
    statusBar:SetAllPoints()
    statusBar:SetStatusBarTexture(settings.barTexture)
    local manaColor = settings.powerColors["MANA"]
    statusBar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b, manaColor.a)
  end

  manaBar.manaMissingStatusBar = _G.CreateFrame("StatusBar", nil, manaBar)
  do
    local statusBar = manaBar.manaMissingStatusBar
    statusBar:SetAllPoints()
    statusBar:SetReverseFill(true)
    statusBar:SetStatusBarTexture(settings.barTexture)
    local color = settings.colors.powerBarBackground
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  --------------------------------------------------------------------------------------------------
  manaBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function manaBar:UNIT_MAXPOWER(unit)
    local manaMax = _G.UnitPowerMax(unit, _G.SPELL_POWER_MANA)
    if manaMax and manaMax ~= 0 then
      self.manaStatusBar:SetMinMaxValues(0, manaMax)
      self.manaMissingStatusBar:SetMinMaxValues(0, manaMax)
    else
      self.manaStatusBar:SetMinMaxValues(0, 1)
      self.manaStatusBar:SetValue(0)
      self.manaMissingStatusBar:SetMinMaxValues(0, 1)
      self.manaMissingStatusBar:SetValue(1)
    end
  end
  manaBar:RegisterUnitEvent("UNIT_MAXPOWER", unit)

  function manaBar:UNIT_POWER_FREQUENT(unit)
    local manaMax = _G.UnitPowerMax(unit, _G.SPELL_POWER_MANA)
    if manaMax and manaMax ~= 0 then
      if _G.UnitIsDeadOrGhost(unit) then
        self.manaStatusBar:SetValue(0)
        self.manaMissingStatusBar:SetValue(manaMax)
      else
        local maxValue = _G.select(2, self.manaStatusBar:GetMinMaxValues())
        local mana     = _G.UnitPower(unit, _G.SPELL_POWER_MANA)
        self.manaStatusBar:SetValue(mana)
        self.manaMissingStatusBar:SetValue(maxValue - mana)
      end
    end
  end
  manaBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", unit)
  --------------------------------------------------------------------------------------------------

  function manaBar:update(unit)
    self:UNIT_MAXPOWER(unit)
    self:UNIT_POWER_FREQUENT(unit)
  end

  return manaBar
end

-- vim: tw=120 sts=2 sw=2 et
