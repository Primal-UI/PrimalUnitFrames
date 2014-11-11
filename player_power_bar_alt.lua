setfenv(1, NinjaKittyUF)

function createAltPowerFrame(attributes)
  local altPowerFrame = _G.CreateFrame("Frame", attributes.name, _G.UIParent)
  altPowerFrame:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  altPowerFrame:SetWidth(attributes.width)
  altPowerFrame:SetHeight(attributes.height)
  altPowerFrame:SetBackdrop(settings.unitFrameBackdrop)
  altPowerFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  altPowerFrame.unit = attributes.unit
  altPowerFrame.maxValue = 1

  altPowerFrame.tagFrame = _G.CreateFrame("Frame", nil, altPowerFrame)
  altPowerFrame.tagFrame.fontString = altPowerFrame.tagFrame:CreateFontString()
  do
    local tagFrame = altPowerFrame.tagFrame
    local fontString = altPowerFrame.tagFrame.fontString
    tagFrame:SetPoint("BOTTOMRIGHT", altPowerFrame, "TOPRIGHT", -4, 0)
    tagFrame:SetHeight(settings.fontSize + 2 * settings.fontSpacing)
    tagFrame:SetBackdrop(settings.defaultBackdrop)
    tagFrame:SetBackdropColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
    tagFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
    fontString:SetFontObject(settings.defaultFont)
    fontString:SetWordWrap(false)
    fontString:SetJustifyH("LEFT")
    fontString:SetJustifyV("MIDDLE")
    fontString:SetPoint("LEFT", altPowerFrame.tagFrame, "LEFT", settings.fontSpacing, 0)
  end

  --------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------
  altPowerFrame.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, altPowerFrame)
  do
    local statusBar = altPowerFrame.backgroundStatusBar
    statusBar:SetPoint("TOPLEFT", altPowerFrame, "TOPLEFT", settings.insets.left,
      -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", altPowerFrame, "BOTTOMRIGHT", -settings.insets.right,
      settings.insets.bottom)
    statusBar:SetReverseFill(true)
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
  end

  altPowerFrame.powerStatusBar = _G.CreateFrame("StatusBar", nil, altPowerFrame)
  do
    local statusBar = altPowerFrame.powerStatusBar
    statusBar:SetPoint("TOPLEFT", altPowerFrame, "TOPLEFT", settings.insets.left,
      -settings.insets.top)
    statusBar:SetPoint("BOTTOMRIGHT", altPowerFrame, "BOTTOMRIGHT", -settings.insets.right,
      settings.insets.bottom)
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetStatusBarColor(settings.colors.health.r, settings.colors.health.g,
      settings.colors.health.b, settings.colors.health.a)
  end

  --------------------------------------------------------------------------------------------------
  altPowerFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function altPowerFrame:UNIT_MAXPOWER(unit, powerType)
    if not (unit == self.unit and powerType == "ALTERNATE") then return end

    local barType, powerMin = _G.UnitAlternatePowerInfo(unit)
    self.maxValue           = _G.UnitPowerMax(unit, _G.SPELL_POWER_ALTERNATE_POWER)

    if not barType --[[or barType == _G.ALT_POWER_TYPE_COUNTER]] then
      return
    end

    local currentPower = _G.UnitPower(unit, _G.SPELL_POWER_ALTERNATE_POWER)

    self.backgroundStatusBar:SetMinMaxValues(powerMin, self.maxValue)
    self.backgroundStatusBar:SetValue(self.maxValue - currentPower)

    self.powerStatusBar:SetMinMaxValues(powerMin, self.maxValue)
    self.powerStatusBar:SetValue(currentPower)

    self.tagFrame.fontString:SetText(currentPower .. " / " .. self.maxValue)
    self.tagFrame.fontString:SetWidth(self.tagFrame.fontString:GetStringWidth())
    self.tagFrame:SetWidth(self.tagFrame.fontString:GetStringWidth() + 2 * settings.fontSpacing)
  end

  function altPowerFrame:UNIT_POWER_FREQUENT(unit, powerType)
    if not (unit == self.unit and powerType == "ALTERNATE") then return end

    local barType  = _G.UnitAlternatePowerInfo(unit)

    if not barType --[[or barType == _G.ALT_POWER_TYPE_COUNTER]] then
      return
    end

    local currentPower = _G.UnitPower(unit, _G.SPELL_POWER_ALTERNATE_POWER)
    self.backgroundStatusBar:SetValue(self.maxValue - currentPower)
    self.powerStatusBar:SetValue(currentPower)

    self.tagFrame.fontString:SetText(currentPower .. " / " .. self.maxValue)
    self.tagFrame.fontString:SetWidth(self.tagFrame.fontString:GetStringWidth())
    self.tagFrame:SetWidth(self.tagFrame.fontString:GetStringWidth() + 2 * settings.fontSpacing)
  end

  function altPowerFrame:UNIT_POWER_BAR_SHOW(unit)
    if unit ~= self.unit then return end
    self:UNIT_MAXPOWER(self.unit, "ALTERNATE")
    --[[
    local powerName = (_G.select(10, _G.UnitAlternatePowerInfo(unit)))
    self.tagFrame.fontString:SetText(powerName)
    self.tagFrame.fontString:SetWidth(self.tagFrame.fontString:GetStringWidth())
    self.tagFrame:SetWidth(self.tagFrame.fontString:GetStringWidth() + 2 * settings.fontSpacing)
    ]]
    self:RegisterUnitEvent("UNIT_MAXPOWER", self.unit)
    self:RegisterUnitEvent("UNIT_POWER_FREQUENT", self.unit)
    self:Show()
  end

  function altPowerFrame:UNIT_POWER_BAR_HIDE(unit)
    if unit ~= self.unit then return end
    self:UNIT_MAXPOWER(self.unit, "ALTERNATE")
    self:UnregisterEvent("UNIT_MAXPOWER")
    self:UnregisterEvent("UNIT_POWER_FREQUENT")
    self:Hide()
  end
  --------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------
  altPowerFrame:SetScript("OnEnter", function(self, motion)
    local _, _, _, _, _, _, _, _, _, powerName, powerTooltip = _G.UnitAlternatePowerInfo("player")
    if powerName and powerTooltip then
      --_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
      --_G.GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 0, 0)
      _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
      _G.GameTooltip:AddLine(powerName, 1, 1, 1, false)
      _G.GameTooltip:AddLine(powerTooltip, nil, nil, nil, true)
      _G.GameTooltip:Show()
    end
  end)

  altPowerFrame:SetScript("OnLeave", function(self, motion)
    _G.GameTooltip:Hide()
  end)

  altPowerFrame:EnableMouse(true)
  --------------------------------------------------------------------------------------------------

  -- Stuff we need to do when PLAYER_LOGIN fires.
  function altPowerFrame:initialize()
    self:Hide()
    self.backgroundStatusBar:SetMinMaxValues(0, 1)
    self.backgroundStatusBar:SetValue(1)
    self.powerStatusBar:SetMinMaxValues(0, 1)
    self.powerStatusBar:SetValue(0)
    self:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", self.unit)
    self:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", self.unit)
  end

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function altPowerFrame:update()
    local barType = _G.UnitAlternatePowerInfo(self.unit)
    if not barType then
      self:UNIT_POWER_BAR_HIDE(self.unit)
      return
    end
    self:UNIT_POWER_BAR_SHOW(self.unit)
    self:UNIT_MAXPOWER(self.unit, "ALTERNATE")
  end

  function altPowerFrame:PLAYER_LOGIN()
    self:initialize()
  end

  function altPowerFrame:PLAYER_ENTERING_WORLD()
    self:update()
  end

  altPowerFrame:RegisterEvent("PLAYER_LOGIN")
  altPowerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
  --------------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------------------

  return altPowerFrame
end

-- I've taken some ideas from:
-- "https://github.com/haste/oUF/blob/master/elements/altpowerbar.lua" and
-- "http://www.curse.com/addons/wow/customplayerpowerbaralt".
--[[
pPowerBarAlt:SetScript("OnEnter", function(self, motion)
  local _, _, _, _, _, _, _, _, _, powerName, powerTooltip =
    _G.UnitAlternatePowerInfo("player")

  if powerName and powerTooltip then
    _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
    _G.GameTooltip:AddLine(powerName, 1, 1, 1, false)
    _G.GameTooltip:AddLine(powerTooltip, nil, nil, nil, true)
    _G.GameTooltip:Show()
  end
end)

pPowerBarAlt:SetScript("OnLeave", function(self, motion)
  _G.GameTooltip:FadeOut()
end)
--]]

-- vim: tw=100 sw=2 et
