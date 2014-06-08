setfenv(1, NinjaKittyUF)

-- Prototype.
HealthBar = {

}

local healthTag = function(unit, healthMax, health, totalAbsorbs)
  if not _G.UnitIsConnected(unit) then
    return --[["|c" .. settings.offlineColor .. settings.strings.offline .. "|r"]]
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
      healthStr = healthStr .. " + " .. _G.string.format("%dk", _G.math.floor((totalAbsorbs + 500) /
        1000))
    end
  end

  return "|c" .. colorStr .. healthStr .. "|r"
end

function createHealthBar(unit, mirror)
  local healthBar = _G.CreateFrame("Frame")
  local frameLevel = healthBar:GetFrameLevel()

  -- We use two bars, mostly because we don't want a semi-transparent black background behind the
  -- would-be flashy white bar. Thus, the "background" is only drawn where the "foreground" isn't.

  healthBar.healthMissingStatusBar = _G.CreateFrame("StatusBar", nil, healthBar)
  do
    local statusBar = healthBar.healthMissingStatusBar
    local color = settings.colors.health
    statusBar:SetAllPoints()
    if not mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  healthBar.healthStatusBar= _G.CreateFrame("StatusBar", nil, healthBar)
  do
    local statusBar = healthBar.healthStatusBar
    statusBar:SetAllPoints()
    if mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(1)
    statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
  end

  healthBar.incomingStatusBar= _G.CreateFrame("StatusBar", nil, healthBar)
  do
    local statusBar = healthBar.incomingStatusBar
    local color = settings.colors.incomingHeals
    statusBar:SetAllPoints()
    if mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
  end

  if not mirror then
    healthBar.fontString = healthBar.healthStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
    healthBar.fontString:SetPoint("LEFT", healthBar.healthStatusBar, "LEFT", settings.fontSpacing, 0)
  else
    healthBar.fontString = healthBar.healthStatusBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")
    healthBar.fontString:SetPoint("RIGHT", healthBar.healthStatusBar, "RIGHT", -settings.fontSpacing, 0)
  end

  healthBar:SetScript("OnSizeChanged", function(self, width, height)
    local availableWidth = width - 4 * settings.fontSpacing
    local leftTagWidth = _G.math.ceil(0.5 * availableWidth - 0.5) - settings.fontSpacing
    self.fontString:SetWidth(leftTagWidth)
  end)

  --------------------------------------------------------------------------------------------------
  healthBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function healthBar:UNIT_HEALTH_FREQUENT(unit)
    local maxValue = _G.select(2, self.healthStatusBar:GetMinMaxValues())
    local healthMax
    local health
    local totalAbsorbs
    local incomingHeals
    local healAbsorbs

    if _G.UnitIsConnected(unit) then
      healthMax     = _G.UnitHealthMax(unit)
      health        = _G.UnitHealth(unit)
      totalAbsorbs  = _G.UnitGetTotalAbsorbs(unit)
      incomingHeals = _G.UnitGetIncomingHeals(unit)
      healAbsorbs   = _G.UnitGetTotalHealAbsorbs(unit)
    else
      healthMax     = maxValue
      health        = maxValue
      totalAbsorbs  = 0
      incomingHeals = 0
      healAbsorbs   = 0
    end

    -- UnitGetTotalHealAbsorbs() returns the amount of healing the unit will absorb without gaining
    -- health. Caused by abilities like Necrotic Strike.

    -- The actual amount of incoming healing. Added to the background bar but ignored by the
    -- health bar.
    if not incomingHeals or not healAbsorbs then
      incomingHeals = 0
    else
      incomingHeals = incomingHeals - healAbsorbs
      if incomingHeals < 0 then incomingHeals = 0 end
    end

    -- I don't think there's a dedicated event to inform us of a unit having died. Update: there is
    -- COMBAT_LOG_EVENT_UNFILTERED and its subevent UNIT_DIED.
    local color, alpha
    if _G.UnitIsDeadOrGhost(unit) then
      color = settings.colors.dead
      alpha = color.a
    --[[
    elseif _G.UnitIsPlayer(unit) then
      local class = (_G.select(2, _G.UnitClassBase(unit)))
      color = class and settings.classColors[class] or settings.colors.health
      alpha = settings.colors.health.a
    ]]
    else
      color = settings.colors.health
      alpha = settings.colors.health.a
    end
    if _G.UnitIsDeadOrGhost(unit) then
      --local color = settings.colors.dead
      self.healthMissingStatusBar:SetStatusBarColor(color.r, color.g, color.b, alpha)
      self.healthMissingStatusBar:SetValue(maxValue)
      self.healthStatusBar:SetValue(0)
      self.incomingStatusBar:SetValue((self.incomingStatusBar:GetMinMaxValues()))
    else
      --local color = settings.colors.health
      self.healthMissingStatusBar:SetStatusBarColor(color.r, color.g, color.b, alpha)

      --local offset = _G.math.floor((health + totalAbsorbs) * self:GetWidth() / maxValue + 0.5)
      local offset = (health + totalAbsorbs) * self:GetWidth() / maxValue
      if not mirror then
        self.incomingStatusBar:SetPoint("TOPLEFT", self, "TOPLEFT", offset, 0)
      else
        self.incomingStatusBar:SetPoint("TOPRIGHT", self, "TOPRIGHT", -offset, 0)
      end
      self.incomingStatusBar:SetMinMaxValues(health + totalAbsorbs, maxValue)
      self.incomingStatusBar:SetValue(health + totalAbsorbs + incomingHeals)
      self.healthStatusBar:SetValue(health + totalAbsorbs)

      self.healthMissingStatusBar:SetValue(maxValue - health - totalAbsorbs - incomingHeals)
    end
    if self:GetHeight() >= settings.fontSize then
      self.fontString:SetText(healthTag(unit, healthMax, health, totalAbsorbs))
    end
  end

  healthBar.UNIT_HEALTH = healthBar.UNIT_HEALTH_FREQUENT

  function healthBar:update(unit)
    local healthMax, totalAbsorbs
    if _G.UnitIsConnected(unit) then
      healthMax = _G.UnitHealthMax(unit)
      totalAbsorbs = _G.UnitGetTotalAbsorbs(unit)
    else
      healthMax = _G.select(2, self.healthStatusBar:GetMinMaxValues())
      totalAbsorbs = 0
    end
    self.healthMissingStatusBar:SetMinMaxValues(0, healthMax + totalAbsorbs)
    self.healthStatusBar:SetMinMaxValues(0, healthMax + totalAbsorbs)
    self:UNIT_HEALTH_FREQUENT(unit)
  end

  function healthBar:initialize(unit)
    self.healthMissingStatusBar:SetMinMaxValues(0, 1)
    self.healthMissingStatusBar:SetValue(0)
    self.healthStatusBar:SetMinMaxValues(0, 1)
    self.healthStatusBar:SetValue(1)
    self.incomingStatusBar:SetMinMaxValues(0, 1)
    self.incomingStatusBar:SetValue(0)
  end

  function healthBar:UNIT_MAXHEALTH(unit)
    self:update(unit)
  end

  function healthBar:UNIT_FACTION(unit)
    self:update(unit)
  end

  function healthBar:UNIT_HEAL_PREDICTION(unit)
    self:UNIT_HEALTH_FREQUENT(unit)
  end

  function healthBar:UNIT_ABSORB_AMOUNT_CHANGED(unit)
    self:UNIT_MAXHEALTH(unit)
  end

  function healthBar:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unit)
    self:UNIT_HEALTH_FREQUENT(unit)
  end

  function healthBar:UNIT_CONNECTION(unit)
    self:update(unit)
  end

  function healthBar:UNIT_PHASE(unit)
    self:update(unit)
  end

  healthBar:RegisterUnitEvent("UNIT_CONNECTION", unit)
  healthBar:RegisterUnitEvent("UNIT_PHASE", unit)
  healthBar:RegisterUnitEvent("UNIT_FACTION", unit)
  healthBar:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
  healthBar:RegisterUnitEvent("UNIT_HEALTH", unit)
  healthBar:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
  healthBar:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
  healthBar:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
  healthBar:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)
  --------------------------------------------------------------------------------------------------

  return healthBar
end

-- vim: tw=100 sw=2 et
