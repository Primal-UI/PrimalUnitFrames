setfenv(1, NinjaKittyUF)

local kittyPowerTag = function(unit)
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

function createKittyPowerFrame(attributes)
  local kittyPowerFrame = _G.CreateFrame("Frame", attributes.name, _G.UIParent)
  kittyPowerFrame:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  kittyPowerFrame:SetWidth(attributes.width)
  kittyPowerFrame:SetHeight(attributes.height)
  kittyPowerFrame:SetBackdrop(settings.unitFrameBackdrop)
  kittyPowerFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  kittyPowerFrame.tagFrame = _G.CreateFrame("Frame", nil, kittyPowerFrame)
  kittyPowerFrame.tagFrame.fontString = kittyPowerFrame.tagFrame:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  kittyPowerFrame.tagFrame.fontString:SetPoint("LEFT", kittyPowerFrame.tagFrame, "LEFT", settings.fontSpacing, 0)
  do
    local tagFrame = kittyPowerFrame.tagFrame
    tagFrame:SetPoint("TOPLEFT", kittyPowerFrame, "BOTTOMLEFT", 4, 0)
    tagFrame:SetHeight(settings.fontSize + 2 * settings.fontSpacing)
    tagFrame:SetBackdrop(settings.kittyPowerFrameBackdrop)
    tagFrame:SetBackdropColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
    tagFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
    --local fontString = kittyPowerFrame.tagFrame.fontString
    --fontString:SetFontObject(settings.defaultFont)
    --fontString:SetWordWrap(false)
    --fontString:SetJustifyH("LEFT")
    --fontString:SetJustifyV("MIDDLE")
    --fontString:SetPoint("LEFT", kittyPowerFrame.tagFrame, "LEFT", settings.fontSpacing, 0)
  end

  --------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------
  kittyPowerFrame.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, kittyPowerFrame)
  do
    local statusBar = kittyPowerFrame.backgroundStatusBar
    statusBar:SetPoint("TOPLEFT", kittyPowerFrame, "TOPLEFT", settings.insets.left,
      -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", kittyPowerFrame, "BOTTOMRIGHT", -settings.insets.right,
      settings.insets.bottom)
    statusBar:SetReverseFill(true)
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
  end

  kittyPowerFrame.energyStatusBar = _G.CreateFrame("StatusBar", nil, kittyPowerFrame)
  do
    local statusBar = kittyPowerFrame.energyStatusBar
    statusBar:SetPoint("TOPLEFT", kittyPowerFrame, "TOPLEFT", settings.insets.left,
      -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", kittyPowerFrame, "BOTTOMRIGHT", -settings.insets.right,
      settings.insets.bottom)
    statusBar:SetStatusBarTexture(settings.barTexture)
    local energyColor = settings.powerColors["ENERGY"]
  end

  kittyPowerFrame.rageStatusBar = _G.CreateFrame("StatusBar", nil, kittyPowerFrame)
  do
    local statusBar = kittyPowerFrame.rageStatusBar
    statusBar:SetPoint("TOPLEFT", kittyPowerFrame, "TOPLEFT", settings.insets.left,
      -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", kittyPowerFrame, "BOTTOMRIGHT", -settings.insets.right,
      settings.insets.bottom)
    statusBar:SetStatusBarTexture(settings.barTexture)
    local color = settings.powerColors["RAGE"]
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  --------------------------------------------------------------------------------------------------
  kittyPowerFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function kittyPowerFrame:UNIT_MAXPOWER(unit)
    local energyMax    = _G.UnitPowerMax(unit, _G.SPELL_POWER_ENERGY)
    local rageMax      = _G.UnitPowerMax(unit, _G.SPELL_POWER_RAGE)
    local energyBarMax = _G.select(2, self.energyStatusBar:GetMinMaxValues())
    local rageBarMax   = _G.select(2, self.rageStatusBar:GetMinMaxValues())
    if energyMax and rageMax and energyBarMax and rageBarMax then
      if energyMax ~= energyBarMax or rageMax ~= rageBarMax then
        self.backgroundStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
        self:UNIT_POWER_FREQUENT(unit)
      end
    end
  end
  kittyPowerFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player")

  function kittyPowerFrame:UNIT_POWER_FREQUENT(unit)
    if _G.UnitIsDeadOrGhost(unit) then
      self.energyStatusBar:SetValue(0)
      self.rageStatusBar:SetValue(0)
      self.backgroundStatusBar:SetValue((_G.select(2, self.backgroundStatusBar:GetMinMaxValues())))
      self.tagFrame:Hide()
    else
      local energyMax = _G.UnitPowerMax(unit, _G.SPELL_POWER_ENERGY)
      local energy    = _G.UnitPower(unit, _G.SPELL_POWER_ENERGY)
      local rageMax   = _G.UnitPowerMax(unit, _G.SPELL_POWER_RAGE)
      local rage      = _G.UnitPower(unit, _G.SPELL_POWER_RAGE)

      if _G.UnitPowerType(unit) == _G.SPELL_POWER_RAGE then
        --local offset = _G.math.floor(self:GetWidth() * rage / rageMax + 0.5)
        local offset = self:GetWidth() * rage / rageMax + 0.5
        self.energyStatusBar:SetPoint("TOPLEFT", self, "TOPLEFT", offset, -settings.insets.top)
        self.energyStatusBar:SetMinMaxValues(rage, energyMax)
        self.rageStatusBar:SetValue(rage)
      end

      if energy * rageMax < rage * energyMax then
        -- The filled portion of the energy bar is shorter than that of the rage bar.
        self.backgroundStatusBar:SetValue(rageMax - rage)
      else
        self.backgroundStatusBar:SetValue(energyMax - energy)
      end

      self.energyStatusBar:SetValue(energy)

      if _G.UnitPowerType(unit) ~= _G.SPELL_POWER_RAGE and energy == energyMax then
        self.tagFrame:Hide()
      else
        self.tagFrame:Show()
        self.tagFrame.fontString:SetText(kittyPowerTag(unit))
        self.tagFrame.fontString:SetWidth(self.tagFrame.fontString:GetStringWidth())
        self.tagFrame:SetWidth(self.tagFrame.fontString:GetStringWidth() + 2 * settings.fontSpacing)
      end
    end
  end
  kittyPowerFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

  function kittyPowerFrame:UNIT_DISPLAYPOWER(unit)
    local energyMax = _G.UnitPowerMax(unit, _G.SPELL_POWER_ENERGY)
    local color     = settings.powerColors["ENERGY"]
    if _G.UnitPowerType(unit) == _G.SPELL_POWER_ENERGY then
      self.energyStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      self.energyStatusBar:SetStatusBarColor(color.r, color.g, color.b, 0.5)
    end
    if _G.UnitPowerType(unit) == _G.SPELL_POWER_RAGE then
    else
      self.energyStatusBar:SetPoint("TOPLEFT", kittyPowerFrame, "TOPLEFT", settings.insets.left,
        -settings.insets.top)
      self.energyStatusBar:SetPoint("BOTTOMRIGHT", kittyPowerFrame, "BOTTOMRIGHT",
        -settings.insets.right,
      settings.insets.bottom)
      self.energyStatusBar:SetMinMaxValues(0, energyMax)
      self.rageStatusBar:SetValue(0)
    end
    self:UNIT_POWER_FREQUENT(unit)
  end
  kittyPowerFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
  --------------------------------------------------------------------------------------------------

  -- Stuff we need to do when PLAYER_LOGIN fires.
  function kittyPowerFrame:initialize()
    local energyMax = _G.UnitPowerMax("player", _G.SPELL_POWER_ENERGY)
    local rageMax   = _G.UnitPowerMax("player", _G.SPELL_POWER_RAGE)
    self.backgroundStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
    self.energyStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
    self.rageStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
  end

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function kittyPowerFrame:update()
    self:UNIT_DISPLAYPOWER("player")
  end

  function kittyPowerFrame:PLAYER_LOGIN()
    self:initialize()
  end
  kittyPowerFrame:RegisterEvent("PLAYER_LOGIN")

  function kittyPowerFrame:PLAYER_ENTERING_WORLD()
    self:update()
  end
  kittyPowerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  --------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------

  return kittyPowerFrame
end

-- vim: tw=100 sw=2 et
