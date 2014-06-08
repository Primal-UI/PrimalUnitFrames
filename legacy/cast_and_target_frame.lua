setfenv(1, NinjaKittyUF)

function createCastAndTargetFrame(attributes)
  local frame = _G.CreateFrame("Frame", attributes.name, _G.UIParent)
  frame:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  frame:SetSize(attributes.width, attributes.height)

  frame.unit = attributes.unit
  frame.maxValue = 1

  frame:SetBackdrop(settings.unitFrameBackdrop)
  frame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  frame.icon = _G.CreateFrame("Frame", nil, frame)
  frame.icon:SetPoint("TOPLEFT")
  frame.icon:SetSize(attributes.height, attributes.height)
  frame.icon:SetBackdrop(settings.unitFrameBackdrop)
  frame.icon:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  frame.icon.texture = frame.icon:CreateTexture()
  frame.icon.texture:SetAllPoints()
  frame.icon:Hide()

  --------------------------------------------------------------------------------------------------
  do
    local unit, mirror = attributes.unit, attributes.mirror
    local frameLevel = frame:GetFrameLevel()

    frame.castStatusBar = _G.CreateFrame("StatusBar", nil, frame)
    do
      local statusBar = frame.castStatusBar
      statusBar:SetPoint("TOPLEFT", frame, "TOPLEFT", settings.spacing, -settings.spacing)
      statusBar:SetPoint("BOTTOMRIGHT", -settings.spacing, settings.spacing)
      if mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetMinMaxValues(0, frame.maxValue)
      statusBar:SetValue(0)
    end

    frame.backgroundStatusBar = _G.CreateFrame("StatusBar", nil, frame)
    do
      local statusBar = frame.backgroundStatusBar
      statusBar:SetPoint("TOPLEFT", frame.castStatusBar)
      statusBar:SetPoint("BOTTOMRIGHT", frame.castStatusBar)
      --statusBar:SetAllPoints()
      if not mirror then statusBar:SetReverseFill(true) end
      statusBar:SetStatusBarTexture(settings.barTexture)
      statusBar:SetStatusBarColor(settings.backgroundColor.r, settings.backgroundColor.g,
        settings.backgroundColor.b, settings.backgroundColor.a)
      statusBar:SetMinMaxValues(0, frame.maxValue)
      statusBar:SetValue(frame.maxValue)
    end
  end

  frame.leftTag   = frame.castStatusBar:CreateFontString()
  frame.centerTag = frame.castStatusBar:CreateFontString()
  frame.rightTag  = frame.castStatusBar:CreateFontString()

  do
    local tag = frame.leftTag
    tag:SetFontObject(settings.defaultFont)
    tag:SetWordWrap(false)
    tag:SetJustifyH("LEFT")
    tag:SetPoint("LEFT", frame.castStatusBar, "LEFT", settings.fontSpacing, 0)
  end

  do
    local tag = frame.rightTag
    tag:SetFontObject(settings.defaultFont)
    tag:SetWordWrap(false)
    tag:SetJustifyH("RIGHT")
    tag:SetPoint("RIGHT", frame.castStatusBar, "RIGHT", -settings.fontSpacing, 0)
  end

  --------------------------------------------------------------------------------------------------
  frame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function frame:UNIT_NAME_UPDATE(unit)
    if _G.UnitExists(unit) then
      -- This condition DOES FAIL! I don't know why and it shouldn't.
      if _G.UnitIsUnit(unit, self.unit .. "target") then
        self.targetText = settings.nameTag(unit)
        self.leftTag:SetText(self.targetText)
        self.leftTag:SetWidth(self.leftTag:GetStringWidth())
        self:Show()
      end
    else
      self.targetText = nil
      if self.casting then
        self.rightTag:SetText()
        self.rightTag:SetWidth(0)
      else
        self:Hide()
      end
    end
  end
  function frame:UNIT_TARGETABLE_CHANGED(unit)
    self:UNIT_NAME_UPDATE(unit)
  end
  function frame:UNIT_FACTION(unit)
    self:UNIT_NAME_UPDATE(unit)
  end
  frame:RegisterUnitEvent("UNIT_NAME_UPDATE", frame.unit .. "target")
  frame:RegisterUnitEvent("UNIT_TARGETABLE_CHANGED", frame.unit .. "target")
  frame:RegisterUnitEvent("UNIT_FACTION", frame.unit .. "target")

  function frame:UNIT_SPELLCAST_START(unit, spell, _, castID, spellID)
    -- Another condition that should never fail as far as I can see, but does.
    if not _G.UnitIsUnit(unit, self.unit) then return end

    local spell, _, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(unit)
    if not spell then
      --self:UNIT_SPELLCAST_STOP(unit, spell, nil, castID, spellID)
      return
    end

    self.casting = true
    self.maxValue = endTime - startTime
    self.value = _G.GetTime() * 1000 - startTime

    self.icon.texture:SetTexture(texture)
    self.castStatusBar:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 0, -settings.spacing)
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
    self:SetScript("OnUpdate", function(self, elapsed)
      self.value = self.value + elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
    end)
    self.icon:Show()

    self.rightTag:SetText(self.targetText)
    --self.rightTag:SetJustifyH("RIGHT")
    self.leftTag:SetText(text)

    self.rightTag:SetWidth(self.rightTag:GetStringWidth())
    self.leftTag:SetPoint("RIGHT", self.rightTag, "LEFT", - 2 * settings.fontSpacing, 0)

    self:Show()
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_START", frame.unit)

  function frame:UNIT_SPELLCAST_STOP(unit, spell, _, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    self.casting = false
    self.icon:Hide()
    self.castStatusBar:SetPoint("TOPLEFT", frame, "TOPLEFT", settings.spacing, -settings.spacing)
    self.castStatusBar:SetValue(0)
    self.backgroundStatusBar:SetValue(self.maxValue)
    self:SetScript("OnUpdate", nil)
    self.leftTag:SetText(self.targetText)
    self.rightTag:SetText()
    if not _G.UnitExists(frame.unit .. "target") then
      self:Hide()
    end -- TODO
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)

  function frame:UNIT_SPELLCAST_FAILED(unit, spell, _, castID, spellID)
    --return self:UNIT_SPELLCAST_STOP(unit, spell, _, castID, spellID)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
  function frame:UNIT_SPELLCAST_INTERRUPTED(unit, spell, _, castID, spellID)
    --return self:UNIT_SPELLCAST_FAILED(unit, spell, _, castID, spellID)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)

  function frame:UNIT_SPELLCAST_DELAYED(unit, spell, rank, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    if not self:IsShown() then return end
    -- This is done in CastingBarFrame.lua from the Blizzard UI. Maybe there's something they know
    -- and I don't.
    if not spell then
      return self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
    end

    return self:UNIT_SPELLCAST_START(unit, spell, rank, castID, spellID)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_DELAYED", unit)

  --frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)

  function frame:UNIT_SPELLCAST_INTERRUPTIBLE(unit)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.casting
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)

  function frame:UNIT_SPELLCAST_NOT_INTERRUPTIBLE(unit)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    local color = settings.colors.castingNotInterruptible
    self.castStatusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)

  function frame:UNIT_SPELLCAST_CHANNEL_START(unit, spell, rank, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end

    local spell, _, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
    if not spell then
      --self:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell, nil, castID, spellID)
      return
    end

    self.casting = false
    self.channeling = true
    self.maxValue = endTime - startTime
    self.value = endTime - _G.GetTime() * 1000

    self.icon.texture:SetTexture(texture)
    self.castStatusBar:SetPoint("TOPLEFT", frame.icon, "TOPRIGHT", 0, -settings.spacing)
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
    self:SetScript("OnUpdate", function(self, elapsed)
      self.value = self.value - elapsed * 1000
      self.castStatusBar:SetValue(self.value)
      self.backgroundStatusBar:SetValue(self.maxValue - self.value)
    end)
    self.icon:Show()

    self.rightTag:SetText(self.targetText)
    self.leftTag:SetText(text)

    self.rightTag:SetWidth(self.rightTag:GetStringWidth())
    self.leftTag:SetPoint("RIGHT", self.rightTag, "LEFT", - 2 * settings.fontSpacing, 0)

    self:Show()
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)

  function frame:UNIT_SPELLCAST_CHANNEL_UPDATE(unit, spell, rank, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    if not self:IsShown() then return end

    local spell, _, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
    if not spell then return end

    self.maxValue = endTime - startTime
    self.value = endTime - _G.GetTime() * 1000
    self.castStatusBar:SetMinMaxValues(0, self.maxValue)
    self.castStatusBar:SetValue(self.value)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)

  function frame:UNIT_SPELLCAST_CHANNEL_STOP(unit, spell, rank, castID, spellID)
    if not _G.UnitIsUnit(unit, self.unit) then return end
    if not self:IsShown() then return end
    if not self.channeling then return end

    self.channeling = false
    self:UNIT_SPELLCAST_STOP(unit, spell, rank, castID, spellID)
  end
  frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)

  --frame:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED", unit)

  -- Stuff we need to do when PLAYER_LOGIN fires.
  function frame:initialize()
    if _G.UnitExists(self.unit) then
      --self.castStatusBar
    end
  end

  function frame:PLAYER_LOGIN()
    self:initialize()
  end
  frame:RegisterEvent("PLAYER_LOGIN")

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires.
  function frame:update()
    local unit = self.unit
    if self.casting or self.channeling then
      self.casting = false
      self.channeling = false
      self.icon:Hide()
      self.castStatusBar:SetPoint("TOPLEFT", frame, "TOPLEFT", settings.spacing, -settings.spacing)
      self.castStatusBar:SetValue(0)
      self.backgroundStatusBar:SetValue(self.maxValue)
      self:SetScript("OnUpdate", nil)
      self.leftTag:SetText()
      self.rightTag:SetText()
    end
    if not _G.UnitExists(unit) and self:IsShown() then
      self:Hide()
      return
    end

    local unitTarget
     -- We can get information faster for certain units?
    if _G.UnitIsUnit(self.unit, "player") then
      unitTarget = "target"
    else
      unitTarget = unit .. "target"
    end
    self:UNIT_NAME_UPDATE(unitTarget)

    local spell, subText, text, texture, startTime, endTime, _, castID, notInterruptible = _G.UnitCastingInfo(unit)
    if spell then
      self:UNIT_SPELLCAST_START(unit, spell, nil, castID, nil)
      return
    end

    local spell, subText, text, texture, startTime, endTime, _, notInterruptible = _G.UnitChannelInfo(unit)
    if spell then
      self:UNIT_SPELLCAST_CHANNEL_START(unit, spell, nil, castID, nil)
    end
  end

  function frame:PLAYER_ENTERING_WORLD()
    self:update()
  end
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")

  -- See http://wowprogramming.com/docs/api_types#unitID
  if frame.unit == "player" then
    -- ...
  elseif frame.unit == "focus" then
    function frame:PLAYER_FOCUS_CHANGED(cause)
      self:update()
    end
    frame:RegisterEvent("PLAYER_FOCUS_CHANGED")
  elseif _G.string.match(frame.unit, "party") then

  elseif _G.string.match(frame.unit, "raid") then

  elseif _G.string.match(frame.unit, "arena") then

  end

  function frame:UNIT_TARGET(unit)
    self:update()
  end
  frame:RegisterUnitEvent("UNIT_TARGET", frame.unit)

  -- This will be faster when we are targeting ourselves.
  function frame:PLAYER_TARGET_CHANGED(cause)
    self:update()
  end
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  --------------------------------------------------------------------------------------------------
end

-- vim: tw=100 sw=2 et
