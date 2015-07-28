local addonName, addon = ...

setfenv(1, addon)

function enableCastFrame(frame)
  frame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)
  frame:update()
end

function disableCastFrame(frame)
  frame:SetScript("OnEvent", function() end)
  frame:Hide()
end

function createCastFrame(attributes)
  local unit = attributes.unit

  local castFrame = _G.CreateFrame("Frame", attributes.name, attributes.parent and _G[attributes.parent] or _G.UIParent)
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
    castFrame.icon:SetPoint(attributes.icon.point, castFrame, attributes.icon.relativePoint, attributes.icon.xOffset,
      attributes.icon.yOffset)
    castFrame.icon:SetHeight(32)
    castFrame.icon:SetWidth(32)
    castFrame.icon:SetBackdrop(settings.unitFrameBackdrop)
    castFrame.icon:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

    castFrame.icon.texture = castFrame.icon:CreateTexture()
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
      local color = settings.colors.background
      statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
      statusBar:SetMinMaxValues(0, castFrame.maxValue)
      statusBar:SetValue(castFrame.maxValue)
    end
  end

  castFrame.leftTag = castFrame.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  castFrame.leftTag:SetPoint("LEFT", castFrame.castStatusBar, "LEFT", settings.fontSpacing, 0)

  castFrame.rightTag = castFrame.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")
  castFrame.rightTag:SetPoint("RIGHT", castFrame.castStatusBar, "RIGHT", -settings.fontSpacing, 0)

  castFrame:SetHeight(attributes.height)
  ----------------------------------------------------------------------------------------------------------------------

  ----------------------------------------------------------------------------------------------------------------------
  castFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function castFrame:UNIT_CONNECTION(unit, hasConnected)
    self:update()
  end

  function castFrame:UNIT_SPELLCAST_START(unit, spell, _, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))

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
      self:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    else
      self:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
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
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    self.casting = false
    self:Hide()
  end

  function castFrame:UNIT_SPELLCAST_FAILED(unit, spell, _, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_INTERRUPTED(unit, spell, _, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_DELAYED(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not self:IsShown() then return end
    -- This is done in CastingBarFrame.lua from the Blizzard UI. Maybe there's something they know
    -- and I don't.
    if not spell then
      return self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
    end

    return self:UNIT_SPELLCAST_START(unit, spell, rank, castID, spellID)
  end

  function castFrame:UNIT_SPELLCAST_SUCCEEDED(unit, spell, _, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    -- ...
  end

  function castFrame:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    local color = settings.colors.casting
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    --if _G.UnitIsEnemy("player", unit) then
    --if _G.UnitCanAttack("player", unit) then
    --self.backgroundStatusBar:SetStatusBarColor(1., 1., 1., .25)
    self.backgroundStatusBar:SetStatusBarColor(1., 1., 1., .35)
    --self.backgroundStatusBar:SetStatusBarColor(1., 1., 1., .4)
    --self.backgroundStatusBar:SetStatusBarColor(.75, .75, .75, .5)
    --self.backgroundStatusBar:SetStatusBarColor(.5, .5, .5, .5)
    if unit ~= "player" and not _G.string.match(unit, "party") then
      --self:SetBackdropBorderColor(1, 1, 1)
      if self.icon then
        --self.icon:SetBackdropBorderColor(1, 1, 1)
      end
    end
  end

  function castFrame:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    local color = settings.colors.castingNotInterruptible
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    local color = settings.colors.background
    self.backgroundStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    --self:SetBackdropBorderColor(0, 0, 0)
    if self.icon then
      --self.icon:SetBackdropBorderColor(0, 0, 0)
    end
  end

  function castFrame:UNIT_SPELLCAST_CHANNEL_START(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))

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
      self:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    else
      self:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
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
      self.backgroundStatusBar:SetMinMaxValues(0, self.maxValue)
      self.backgroundStatusBar:SetValue(self.maxValue)
    end
  end

  function castFrame:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not self.channeling then return end

    self.channeling = false
    self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
  end
  ----------------------------------------------------------------------------------------------------------------------

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

  function castFrame:initialize()
    self:RegisterUnitEvent("UNIT_CONNECTION", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", self.unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", self.unit)

    -- The OnUpdate handler is only run if the frame is visible!
    self:SetScript("OnUpdate", onUpdate)

    self:SetScript("OnShow", function(self)
      self:update()
    end)
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
  castFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", castFrame.unit)

  function castFrame:UNIT_PHASE(unit)
    self:update()
  end
  castFrame:RegisterUnitEvent("UNIT_PHASE", castFrame.unit)

  function castFrame:PLAYER_ENTERING_WORLD()
    self:update()
  end
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
  elseif _G.string.match(castFrame.unit, "arena") then
    function castFrame:ARENA_OPPONENT_UPDATE(unit, eventType)
      self:update()
    end
    castFrame:RegisterUnitEvent("ARENA_OPPONENT_UPDATE", castFrame.unit)
  elseif _G.string.match(castFrame.unit, "party") then
    function castFrame:GROUP_ROSTER_UPDATE()
      self:update()
    end
    castFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
  else
    _G.error()
  end

  return castFrame
end

-- vim: tw=120 sts=2 sw=2 et
