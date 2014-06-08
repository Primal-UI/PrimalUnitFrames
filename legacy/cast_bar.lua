setfenv(1, NinjaKittyUF)

function createCastBar(unit, mirror, parent)
  local castBar = _G.CreateFrame("Frame", nil, parent)

  castBar.unit = unit
  castBar.maxValue = 1

  castBar.icon = _G.CreateFrame("Frame", nil, castBar)
  castBar.icon:SetPoint("TOPLEFT", -1, 1)
  castBar.icon:SetPoint("BOTTOM", -1, -1)
  castBar.icon:SetScript("OnSizeChanged", function(self, width, height)
    self:SetWidth(height)
  end)
  castBar.icon:SetFrameLevel(parent:GetFrameLevel() - 1)
  castBar.icon:SetBackdrop(settings.unitFrameBackdrop)
  castBar.icon:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  castBar.icon.texture = castBar.icon:CreateTexture(--[[nil, "BACKGROUND"]])
  castBar.icon.texture:SetAllPoints()
  castBar.icon:Hide()

  do
    castBar.castStatusBar = _G.CreateFrame("StatusBar", nil, castBar)
    do
      local statusBar = castBar.castStatusBar
      statusBar:SetAllPoints()
      if mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetMinMaxValues(0, castBar.maxValue)
      statusBar:SetValue(0)
    end

    castBar.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, castBar)
    do
      local statusBar = castBar.backgroundStatusBar
      statusBar:SetAllPoints()
      if not mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetStatusBarColor(settings.backgroundColor.r, settings.backgroundColor.g,
        settings.backgroundColor.b, settings.backgroundColor.a)
      statusBar:SetMinMaxValues(0, castBar.maxValue)
      statusBar:SetValue(castBar.maxValue)
    end
  end

  castBar.leftTag = castBar.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
  castBar.centerTag = castBar.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringCenter")
  castBar.rightTag = castBar.castStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")

  castBar.leftTag:SetPoint("LEFT", castBar.castStatusBar, "LEFT", settings.fontSpacing, 0)

  castBar.centerTag:SetPoint("LEFT", castBar.leftTag, "RIGHT", settings.fontSpacing, 0)
  castBar.centerTag:SetPoint("RIGHT", castBar.rightTag, "LEFT", settings.fontSpacing, 0)

  castBar.rightTag:SetJustifyH("RIGHT")
  castBar.rightTag:SetPoint("RIGHT", castBar.castStatusBar, "RIGHT", -settings.fontSpacing, 0)

  function castBar:realignTags()
    if not self.casting and not self.channeling and self.leftTag:IsTruncated() then
      self.leftTag:SetWidth(self:GetWidth())
    end
    if self.rightTag:IsTruncated() then
      self.rightTag:SetWidth(self:GetWidth())
    end
    local leftTagWidth = self.leftTag:GetStringWidth() or 0
    local rightTagWidth = self.rightTag:GetStringWidth() or 0
    self.leftTag:SetWidth(leftTagWidth + 2) -- TODO: no magic numbers.
    self.rightTag:SetWidth(rightTagWidth + 2) -- TODO: no magic numbers.
  end

  --------------------------------------------------------------------------------------------------
  castBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function castBar:UNIT_CONNECTION(unit, hasConnected)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    self:update(self.unit)
  end

  function castBar:UNIT_SPELLCAST_START(unit, spell, _, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end

    local spell, _, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(unit)
    if not spell then
      return
    end

    self.casting = true
    self.channeling = false
    self.maxValue = endTime - startTime
    self.value = _G.GetTime() * 1000 - startTime

    self.icon.texture:SetTexture(texture)
    self.castStatusBar:SetPoint("TOPLEFT", self.icon, "TOPRIGHT", 0, -settings.spacing)
    if notInterruptible then
      local color = settings.colors.castingNotInterruptible
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      local color = settings.colors.casting
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    self.castStatusBar:SetMinMaxValues(0, self.maxValue)
    self.castStatusBar:SetValue(self.value)
    self.backgroundStatusBar:SetAllPoints(self.castStatusBar)
    self.backgroundStatusBar:SetMinMaxValues(0, self.maxValue)
    self.backgroundStatusBar:SetValue(self.maxValue)
    self.icon:Show()

    --[[
    do
      local color
      if _G.UnitIsPlayer(unit) then
        local class = (_G.select(2, _G.UnitClassBase(unit)))
        color = class and settings.classColors[class].colorStr or "ffffffff"
      else
        color = "ffffffff"
      end
      self.leftTag:SetText("|c" .. color .. text .. "|r")
    end
    ]]
    self.leftTag:SetText(text)

    self.centerTag:SetText()

    self.rightTag:SetWidth(self.rightTag:GetStringWidth())
    self.leftTag:SetPoint("RIGHT", self.rightTag, "LEFT", -2 * settings.fontSpacing, 0)

    self:Show()
  end

  function castBar:UNIT_SPELLCAST_STOP(unit, spell, _, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    self.casting = false
    self.icon:Hide()
    self.castStatusBar:SetAllPoints()
    self.backgroundStatusBar:SetAllPoints()
    self.leftTag:ClearAllPoints()
    self.leftTag:SetPoint("LEFT", castBar.castStatusBar, "LEFT", settings.fontSpacing, 0)
    self.castStatusBar:SetValue(0)
    self.backgroundStatusBar:SetValue(self.maxValue)
    tagGroups.name.reset(unit)
    tagGroups.spec.reset(unit)
    self:realignTags()
  end

  function castBar:UNIT_SPELLCAST_FAILED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castBar:UNIT_SPELLCAST_INTERRUPTED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castBar:UNIT_SPELLCAST_DELAYED(unit, spell, rank, castID, spellID)
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

  function castBar:UNIT_SPELLCAST_SUCCEEDED(unit, spell, _, castID, spellID)
    -- ...
  end

  function castBar:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.casting
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  function castBar:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.castingNotInterruptible
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  function castBar:UNIT_SPELLCAST_CHANNEL_START(unit, spell, rank, castID, spellID)
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

    self.icon.texture:SetTexture(texture)
    self.castStatusBar:SetPoint("TOPLEFT", self.icon, "TOPRIGHT", 0, -settings.spacing)
    if notInterruptible then
      local color = settings.colors.castingNotInterruptible
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    else
      local color = settings.colors.casting
      self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    end
    self.castStatusBar:SetMinMaxValues(0, self.maxValue)
    self.castStatusBar:SetValue(self.value)
    self.backgroundStatusBar:SetAllPoints(self.castStatusBar)
    self.backgroundStatusBar:SetMinMaxValues(0, self.maxValue)
    self.backgroundStatusBar:SetValue(self.maxValue)
    self.icon:Show()

    --[[
    do
      local color
      if _G.UnitIsPlayer(unit) then
        local class = (_G.select(2, _G.UnitClassBase(unit)))
        color = class and settings.classColors[class].colorStr or "ffffffff"
      else
        color = "ffffffff"
      end
      self.leftTag:SetText("|c" .. color .. text .. "|r")
    end
    ]]
    self.leftTag:SetText(text)

    self.centerTag:SetText()

    self.rightTag:SetWidth(self.rightTag:GetStringWidth())
    self.leftTag:SetPoint("RIGHT", self.rightTag, "LEFT", -2 * settings.fontSpacing, 0)

    self:Show()
  end

  function castBar:UNIT_SPELLCAST_CHANNEL_UPDATE(unit, spell, rank, castID, spellID)
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

  function castBar:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell, rank, castID, spellID)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    if not self.channeling then return end

    self.channeling = false
    self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
  end

  --[[function castBar:UNIT_PHASE(unit)
    -- ...
  end]]
  --------------------------------------------------------------------------------------------------

  local function onUpdate(self, elapsed)
    if self.casting then
      self.value = self.value + elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
      if self.value >= self.maxValue then
        self:UNIT_SPELLCAST_STOP(self.unit)
      end
    elseif self.channeling then
      self.value = self.value - elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
      if self.value <= 0 then
        self:UNIT_SPELLCAST_CHANNEL_STOP(self.unit)
      end
    end
  end

  local function onShow(self)
    self:RegisterUnitEvent("UNIT_CONNECTION", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)
    self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)

    self:SetScript("OnUpdate", onUpdate)
    self.rangeTag:enable()
  end


  local function onHide(self)
    self:UnregisterAllEvents()
    self:SetScript("OnUpdate", nil)
    self.rangeTag:disable()
  end

  function castBar:initialize(unit)
    self.rangeTag = RangeTag:new(unit, function(text)
      local stringWidth = self.rightTag:GetStringWidth()
      self.rightTag:SetText(text)
      if stringWidth ~= self.rightTag:GetStringWidth() then
        self:realignTags()
      end
    end)
    registerTag(tagGroups.name, unit, function(text)
      if not (self.casting or self.channeling) then
        self.leftTag:SetText(text)
        self:realignTags()
      end
    end)
    registerTag(tagGroups.spec, unit, function(text)
      if not (self.casting or self.channeling) then
        self.centerTag:SetText(text)
        self:realignTags()
      end
    end)

    -- The OnShow handler is not run if the frame is implicitly shown upon its creation.
    self:SetScript("OnShow", onShow)
    self:SetScript("OnHide", onHide)

    if self:IsVisible() then
      self:GetScript("OnShow")(self)
    end
  end

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function castBar:update(unit)
    --if not self:IsVisible() then return end

    if self.casting or self.channeling then
      self.casting = false
      self.channeling = false
      self.icon:Hide()
      self.castStatusBar:SetAllPoints()
      self.backgroundStatusBar:SetAllPoints()
      self.leftTag:ClearAllPoints()
      self.leftTag:SetPoint("LEFT", castBar.castStatusBar, "LEFT", settings.fontSpacing, 0)
      self.castStatusBar:SetValue(0)
      self.backgroundStatusBar:SetValue(self.maxValue)
    end

    local spell, subText, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(unit)
    if spell then
      self:UNIT_SPELLCAST_START(unit, spell, nil, castID, nil)
    else
      local spell, subText, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
      if spell then
        self:UNIT_SPELLCAST_CHANNEL_START(unit, spell, nil, castID, nil)
      end
    end

    self.rangeTag:update()
    tagGroups.name.update(unit)
    tagGroups.spec.update(unit)
  end

  return castBar
end

-- vim: tw=100 sw=2 et
