-- TODO: Don't use StatusBar frames.  Just use textures.

local addonName, addon = ...

setfenv(1, addon)

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
  local self = _G.CreateFrame("Frame", attributes.name, _G.UIParent)
  self:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  self:SetWidth(attributes.width)
  self:SetHeight(attributes.height)
  self:SetBackdrop(settings.unitFrameBackdrop)
  self:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  self.tagFrame = _G.CreateFrame("Frame", nil, self)
  self.tagFrame.fontString = self.tagFrame:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  self.tagFrame.fontString:SetPoint("LEFT", self.tagFrame, "LEFT", settings.fontSpacing, 0)
  do
    local tagFrame = self.tagFrame
    tagFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 4, 0)
    tagFrame:SetHeight(settings.fontSize + 2 * settings.fontSpacing)
    tagFrame:SetBackdrop(settings.kittyPowerFrameBackdrop)
    tagFrame:SetBackdropColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
    tagFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
  end

  self.healthFrame = _G.CreateFrame("Frame", nil, self)
  self.healthFrame.fontString = self.healthFrame:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  self.healthFrame.fontString:SetPoint("LEFT", self.healthFrame, "LEFT", settings.fontSpacing, 0)
  do
    local frame = self.healthFrame
    frame:SetPoint("TOPLEFT", self, "BOTTOM", 5, 0)
    --frame:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", -4, 0)
    frame:SetHeight(settings.fontSize + 2 * settings.fontSpacing)
    frame:SetBackdrop(settings.kittyPowerFrameBackdrop)
    frame:SetBackdropColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
    frame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
  end
  self.healthTag = PercentHealthTag:new("target", function(number)
    if number and 25 <= number and number <= 50 then
      self.healthFrame.fontString:SetText(number)
      self.healthFrame.fontString:SetWidth(self.healthFrame.fontString:GetStringWidth())
      self.healthFrame:SetWidth(self.healthFrame.fontString:GetStringWidth() + 2 * settings.fontSpacing)
      self.healthFrame:Show()
    else
      self.healthFrame:Hide()
    end
  end)

  ----------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------
  self.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, self)
  do
    local statusBar = self.backgroundStatusBar
    statusBar:SetPoint("TOPLEFT", settings.insets.left, -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", -settings.insets.right, settings.insets.bottom)
    statusBar:SetReverseFill(true)
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
  end

  self.energyStatusBar = _G.CreateFrame("StatusBar", nil, self)
  do
    local statusBar = self.energyStatusBar
    statusBar:SetPoint("TOPLEFT", settings.insets.left, -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", -settings.insets.right, settings.insets.bottom)
    statusBar:SetStatusBarTexture(settings.barTexture)
    local energyColor = settings.powerColors["ENERGY"]
  end

  self.rageStatusBar = _G.CreateFrame("StatusBar", nil, self)
  do
    local statusBar = self.rageStatusBar
    statusBar:SetPoint("TOPLEFT", settings.insets.left, -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", -settings.insets.right, settings.insets.bottom)
    statusBar:SetStatusBarTexture(settings.barTexture)
    local color = settings.powerColors["RAGE"]
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  ----------------------------------------------------------------------------------------------------------------------
  self:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function self:UNIT_MAXPOWER(unit)
    local energyMax    = _G.UnitPowerMax(unit, _G.SPELL_POWER_ENERGY)
    local rageMax      = _G.UnitPowerMax(unit, _G.SPELL_POWER_RAGE)
    local energyBarMax = _G.select(2, self.energyStatusBar:GetMinMaxValues())
    local rageBarMax   = _G.select(2, self.rageStatusBar:GetMinMaxValues())
    if energyMax and rageMax and energyBarMax and rageBarMax then
      if energyMax ~= energyBarMax or rageMax ~= rageBarMax then
        self.backgroundStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
        self.energyStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
        self.rageStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
        self:UNIT_POWER_FREQUENT(unit)
      end
    end
  end
  self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

  function self:UNIT_POWER_FREQUENT(unit)
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

      self.energyStatusBar:SetValue(energy)

      if _G.UnitPowerType(unit) == _G.SPELL_POWER_RAGE then
        local offset = self.rageStatusBar:GetWidth() * rage / rageMax -- Rounding this doesn't work out.
        self.energyStatusBar:SetPoint("TOPLEFT", settings.insets.left + offset, -settings.insets.top)
        self.energyStatusBar:SetMinMaxValues(rage, energyMax)
        self.rageStatusBar:SetValue(rage)
      end

      if _G.UnitPowerType(unit) == _G.SPELL_POWER_RAGE and energy * rageMax < rage * energyMax then
        -- The filled portion of the energy bar is shorter than that of the rage bar.
        self.backgroundStatusBar:SetValue(rageMax - rage)
      else
        self.backgroundStatusBar:SetValue(energyMax - energy)
      end

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
  self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")

  function self:UNIT_DISPLAYPOWER(unit)
    local energyMax = _G.UnitPowerMax(unit, _G.SPELL_POWER_ENERGY)
    local color     = settings.powerColors["ENERGY"]
    if _G.UnitPowerType(unit) == _G.SPELL_POWER_ENERGY then
      self.energyStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      self.energyStatusBar:SetStatusBarColor(color.r, color.g, color.b, 0.5)
    end
    if _G.UnitPowerType(unit) == _G.SPELL_POWER_RAGE then
    else
      self.energyStatusBar:SetPoint("TOPLEFT", settings.insets.left, -settings.insets.top)
      self.energyStatusBar:SetPoint("BOTTOMRIGHT", -settings.insets.right, settings.insets.bottom)
      self.energyStatusBar:SetMinMaxValues(0, energyMax)
      self.rageStatusBar:SetValue(0)
    end
    self:UNIT_POWER_FREQUENT(unit)
  end
  self:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
  ----------------------------------------------------------------------------------------------------------------------

  -- Stuff we need to do when PLAYER_LOGIN fires.
  function self:initialize()
    local energyMax = _G.UnitPowerMax("player", _G.SPELL_POWER_ENERGY)
    local rageMax   = _G.UnitPowerMax("player", _G.SPELL_POWER_RAGE)
    self.backgroundStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
    self.energyStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
    self.rageStatusBar:SetMinMaxValues(0, _G.math.max(energyMax, rageMax))
    self.healthTag:enable()
  end

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function self:update()
    self:UNIT_DISPLAYPOWER("player")
    self.healthTag:update()
  end

  function self:PLAYER_LOGIN()
    self:initialize()
  end
  self:RegisterEvent("PLAYER_LOGIN")

  function self:PLAYER_ENTERING_WORLD()
    self:update()
  end
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  ----------------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------------

  return self
end

-- vim: tw=120 sts=2 sw=2 et
