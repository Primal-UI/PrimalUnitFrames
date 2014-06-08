setfenv(1, NinjaKittyUF)

function createCastFrame(attributes)
  local unit = attributes.unit

  local castFrame = _G.CreateFrame("Frame", attributes.name, _G.UIParent)
  castFrame:SetFrameLevel(10)
  castFrame:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  castFrame:SetWidth(attributes.width)

  castFrame.unit = attributes.unit
  castFrame.maxValue = 1

  castFrame:SetBackdrop(settings.unitFrameBackdrop)
  castFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  if attributes.icon then
    castFrame.icon = _G.CreateFrame("Frame", nil, castFrame)
    castFrame.icon:SetPoint(attributes.icon.point, castFrame, attributes.icon.relativePoint,
      attributes.icon.xOffset, attributes.icon.yOffset)
    castFrame.icon:SetHeight(32)
    castFrame.icon:SetWidth(32)
    castFrame.icon:SetBackdrop(settings.unitFrameBackdrop)
    castFrame.icon:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

    castFrame.icon.texture = castFrame.icon:CreateTexture(--[[nil, "BACKGROUND"]])
    castFrame.icon.texture:SetAllPoints()
  end

  do
    castFrame.castStatusBar = _G.CreateFrame("StatusBar", nil, castFrame)
    do
      local statusBar = castFrame.castStatusBar
      statusBar:SetPoint("TOPLEFT", castFrame, "TOPLEFT", settings.spacing, -settings.spacing)
      statusBar:SetPoint("BOTTOMRIGHT", castFrame, "BOTTOMRIGHT", -1, 1)
      if mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetMinMaxValues(0, castFrame.maxValue)
      statusBar:SetValue(0)
    end

    castFrame.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, castFrame)
    do
      local statusBar = castFrame.backgroundStatusBar
      statusBar:SetPoint("TOPLEFT", castFrame, "TOPLEFT", settings.spacing, -settings.spacing)
      statusBar:SetPoint("BOTTOMRIGHT", castFrame, "BOTTOMRIGHT", -1, 1)
      if not mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
        settings.colors.background.b, settings.colors.background.a)
      statusBar:SetMinMaxValues(0, castFrame.maxValue)
      statusBar:SetValue(castFrame.maxValue)
    end
  end

  castFrame.leftTag = castFrame.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  castFrame.leftTag:SetPoint("LEFT", castFrame.castStatusBar, "LEFT", settings.fontSpacing, 0)

  castFrame.rightTag = castFrame.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")
  castFrame.rightTag:SetPoint("RIGHT", castFrame.castStatusBar, "RIGHT", -settings.fontSpacing, 0)

  castFrame:SetHeight(attributes.height)
  --------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------
  castFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function castFrame:UNIT_CONNECTION(unit, hasConnected)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    self:update()
  end

  function castFrame:UNIT_SPELLCAST_START(unit, spell, _, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end

    local spell, _, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(unit)
    if not spell then
      return
    end

    self.casting = true
    self.channeling = false
    self.maxValue = endTime - startTime
    self.value = _G.GetTime() * 1000 - startTime

    if self.icon then self.icon.texture:SetTexture(texture) end
    if notInterruptible then
      local color = settings.colors.castingNotInterruptible
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      local color = settings.colors.casting
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    self.castStatusBar:SetMinMaxValues(0, self.maxValue)
    self.castStatusBar:SetValue(self.value)
    self.backgroundStatusBar:SetMinMaxValues(0, self.maxValue)
    self.backgroundStatusBar:SetValue(self.maxValue)

    if self:GetHeight() >= settings.fontSize then
      self.leftTag:SetText(text)
    end

    self:Show()
  end

  function castFrame:UNIT_SPELLCAST_STOP(unit, spell, _, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    self.casting = false
    self:Hide()
  end

  function castFrame:UNIT_SPELLCAST_FAILED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_INTERRUPTED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_DELAYED(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end
    if not self:IsShown() then return end
    -- This is done in CastingBarFrame.lua from the Blizzard UI. Maybe there's something they know
    -- and I don't.
    if not spell then
      return self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
    end

    return self:UNIT_SPELLCAST_START(unit, spell, rank, castID, spellID)
  end

  function castFrame:UNIT_SPELLCAST_SUCCEEDED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.casting
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  function castFrame:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.castingNotInterruptible
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  function castFrame:UNIT_SPELLCAST_CHANNEL_START(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end

    local spell, _, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
    if not spell then
      return
    end

    self.casting = false
    self.channeling = true
    self.maxValue = endTime - startTime
    self.value = endTime - _G.GetTime() * 1000

    if self.icon then self.icon.texture:SetTexture(texture) end
    if notInterruptible then
      local color = settings.colors.castingNotInterruptible
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      local color = settings.colors.casting
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    self.castStatusBar:SetMinMaxValues(0, self.maxValue)
    self.castStatusBar:SetValue(self.value)
    self.backgroundStatusBar:SetMinMaxValues(0, self.maxValue)
    self.backgroundStatusBar:SetValue(self.maxValue)

    if self:GetHeight() >= settings.fontSize then
      self.leftTag:SetText(text)
    end

    self:Show()
  end

  function castFrame:UNIT_SPELLCAST_CHANNEL_UPDATE(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))

    local spell, _, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
    if not spell then return end

    self.maxValue = endTime - startTime
    self.value = endTime - _G.GetTime() * 1000

    if self:IsShown() then
      self.castStatusBar:SetMinMaxValues(0, self.maxValue)
      self.castStatusBar:SetValue(self.value)
    end
  end

  function castFrame:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not self.channeling then return end

    self.channeling = false
    self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
  end
  --------------------------------------------------------------------------------------------------

  local function onUpdate(self, elapsed)
    if not self.casting and not self.channeling then return end
    local remainingTime
    if self.casting then
      self.value = self.value + elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
      if self.value >= self.maxValue then
        self:UNIT_SPELLCAST_STOP(self.unit)
      end
      remainingTime = _G.math.floor((self.maxValue - self.value) / 100 + 0.5) / 10
    elseif self.channeling then
      self.value = self.value - elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
      if self.value <= 0 then
        self:UNIT_SPELLCAST_CHANNEL_STOP(self.unit)
      end
      remainingTime = _G.math.floor(self.value / 100 + 0.5) / 10
    end
    if self:GetHeight() >= settings.fontSize then
      self.rightTag:SetText(_G.string.format("%.1f", remainingTime))
    end
  end

  local function enable()
    castFrame:RegisterUnitEvent("UNIT_CONNECTION", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    castFrame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)

    castFrame:SetScript("OnUpdate", onUpdate)
  end

  local function disable()
    castFrame:UnregisterAllEvents()
    castFrame:SetScript("OnUpdate", nil)
  end

  function castFrame:initialize(unit)
    enable()
  end

  function castFrame:PLAYER_LOGIN()
    self:initialize()
  end
  castFrame:RegisterEvent("PLAYER_LOGIN")

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function castFrame:update()
    --if not self:IsVisible() then return end

    if self.casting or self.channeling then
      self.casting = false
      self.channeling = false
      self.castStatusBar:SetValue(0)
      self.backgroundStatusBar:SetValue(self.maxValue)
    end

    local spell, subText, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(self.unit)
    if spell then
      self:UNIT_SPELLCAST_START(self.unit, spell, nil, castID, nil)
    else
      local spell, subText, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(self.unit)
      if spell then
        self:UNIT_SPELLCAST_CHANNEL_START(self.unit, spell, nil, castID, nil)
      else
        self:Hide()
      end
    end
  end

  function castFrame:UNIT_NAME_UPDATE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    self:update()
  end

  function castFrame:UNIT_PHASE(unit)
    self:update()
  end

  function castFrame:UNIT_CONNECTION(unit, hasConnected)
    self:update()
  end

  function castFrame:PLAYER_ENTERING_WORLD()
    self:update()
  end

  castFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", castFrame.unit)
  castFrame:RegisterUnitEvent("UNIT_PHASE", castFrame.unit)
  castFrame:RegisterUnitEvent("UNIT_CONNECTION", castFrame.unit)
  castFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

  if castFrame.unit == "player" then
    -- ...
  elseif castFrame.unit == "target" then
    function castFrame:PLAYER_TARGET_CHANGED(cause)
      self:update()
    end
    castFrame:RegisterEvent("PLAYER_TARGET_CHANGED") -- This is faster than UNIT_TARGET.
  elseif castFrame.unit == "focus" then
    function castFrame:PLAYER_FOCUS_CHANGED(cause)
      self:update()
    end
    castFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
  else
    _G.assert(nil)
  end

  return castFrame
end

-- vim: tw=100 sw=2 et
