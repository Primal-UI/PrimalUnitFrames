setfenv(1, NinjaKittyUF)

-- Prototype.
HeaderBar = {

}

function HeaderBar:new(unit, leftTag, centerTag, rightTag)
  local bar = _G.setmetatable(_G.CreateFrame("Frame"), { __index = self})
  return bar
end

function HeaderBar:new(unit, attributes)
  return createHeaderBar(unit, attributes.mirror)
end

function createHeaderBar(unit, mirror)
  local headerBar = _G.CreateFrame("Frame")

  --[[
  headerBar:SetBackdrop(settings.headerBarBackdrop)
  headerBar:SetBackdropColor(settings.colors.background.r, settings.colors.background.g,
    settings.colors.background.b, settings.colors.background.a)
  --]]

  headerBar.healthMissingStatusBar = _G.CreateFrame("StatusBar", nil, headerBar)
  do
    local statusBar = headerBar.healthMissingStatusBar
    local color = settings.colors.health
    statusBar:SetAllPoints()
    if not mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
  end

  headerBar.healthStatusBar= _G.CreateFrame("StatusBar", nil, headerBar)
  do
    local statusBar = headerBar.healthStatusBar
    statusBar:SetAllPoints()
    if mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(1)
    statusBar:SetStatusBarColor(settings.colors.background.r, settings.colors.background.g,
      settings.colors.background.b, settings.colors.background.a)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(1)
  end

  headerBar.incomingStatusBar= _G.CreateFrame("StatusBar", nil, headerBar)
  do
    local statusBar = headerBar.incomingStatusBar
    local color = settings.colors.incomingDark
    statusBar:SetAllPoints()
    if mirror then
      statusBar:SetReverseFill(true)
    end
    statusBar:SetStatusBarTexture(settings.barTexture)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, color.a)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(0)
  end

  headerBar.leftFontString = headerBar.healthStatusBar:CreateFontString(nil, nil,
    "NinjaKittyFontStringLeft")
  headerBar.centerFontString = headerBar.healthStatusBar:CreateFontString(nil, nil,
    "NinjaKittyFontStringCenter")
  headerBar.rightFontString = headerBar.healthStatusBar:CreateFontString(nil, nil,
    "NinjaKittyFontStringRight")

  headerBar.leftFontString:SetPoint("LEFT", headerBar, "LEFT", settings.fontSpacing, 0)

  headerBar.centerFontString:SetPoint("LEFT", headerBar.leftFontString, "RIGHT",
    settings.fontSpacing, 0)
  headerBar.centerFontString:SetPoint("RIGHT", headerBar.rightFontString, "LEFT",
    settings.fontSpacing, 0)

  headerBar.rightFontString:SetPoint("RIGHT", headerBar, "RIGHT", -settings.fontSpacing, 0)
  --headerBar.rightFontString:SetWordWrap(false)

  function headerBar:realignTags()
    if self.leftFontString:IsTruncated() then
      self.leftFontString:SetWidth(self:GetWidth())
    end
    if self.rightFontString:IsTruncated() then
      self.rightFontString:SetWidth(self:GetWidth())
    end
    local leftTagWidth = self.leftFontString:GetStringWidth() or 0
    local rightTagWidth = self.rightFontString:GetStringWidth() or 0
    self.leftFontString:SetWidth(leftTagWidth + 2) -- TODO: no magic numbers.
    self.rightFontString:SetWidth(rightTagWidth + 2) -- TODO: no magic numbers.
  end

  local function onShow(self)
    self.rangeTag:enable()
    self.nameTag:enable()
    self.arenaIDTag:enable()
    self.specTag:enable()
  end

  local function onHide(self)
    self.rangeTag:disable()
    self.nameTag:disable()
    self.arenaIDTag:disable()
    self.specTag:disable()
  end

  function headerBar:initialize(unit)
    self.rangeTag = RangeTag:new(unit, function(text)
      local stringWidth = self.rightFontString:GetStringWidth()
      self.rightFontString:SetText(text)
      if stringWidth ~= self.rightFontString:GetStringWidth() then
        self:realignTags()
      end
    end)
    do
      local nameText, arenaID
      self.nameTag = NameTag:new(unit, function(text)
        nameText = text
        if arenaID then
          self.leftFontString:SetText("[" .. arenaID .. "] " .. nameText)
        else
          self.leftFontString:SetText(nameText)
        end
        self:realignTags()
      end)
      self.arenaIDTag = ArenaIDTag:new(unit, function(text)
        arenaID = text
        if arenaID then
          self.leftFontString:SetText("[" .. arenaID .. "] " .. nameText)
        else
          self.leftFontString:SetText(nameText)
        end
        self:realignTags()
      end)
    end
    self.specTag = SpecTag:new(unit, function(text)
      self.centerFontString:SetText(text)
      self:realignTags()
    end)

    -- The OnShow handler is not run if the frame is implicitly shown upon its creation.
    self:SetScript("OnShow", onShow)
    self:SetScript("OnHide", onHide)

    if self:IsVisible() then
      self:GetScript("OnShow")(self)
    end
  end

  function headerBar:update(unit)
    self.rangeTag:update()
    self.nameTag:update()
    self.arenaIDTag:update()
    self.specTag:update()

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

  headerBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function headerBar:UNIT_HEALTH_FREQUENT(unit)
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

    -- I don't think there's a dedicated event to inform us of a unit having died.
    local color, alpha
    if _G.UnitIsDeadOrGhost(unit) then
      color = settings.colors.dead
      alpha = color.a
    --[[
    elseif _G.UnitIsPlayer(unit) then
      local class = (_G.select(2, _G.UnitClassBase(unit)))
      color = class and settings.classColors[class] or settings.colors.healthDark
      alpha = settings.colors.healthDark.a
    ]]
    else
      color = settings.colors.healthDark
      alpha = settings.colors.healthDark.a
    end
    if _G.UnitIsDeadOrGhost(unit) then
      --local color = settings.colors.dead
      self.healthMissingStatusBar:SetStatusBarColor(color.r, color.g, color.b, alpha)
      self.healthMissingStatusBar:SetValue(maxValue)
      self.healthStatusBar:SetValue(0)
      self.incomingStatusBar:SetValue((self.incomingStatusBar:GetMinMaxValues()))
    else
      --local color = settings.colors.healthDark
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
  end

  headerBar.UNIT_HEALTH = headerBar.UNIT_HEALTH_FREQUENT

  function headerBar:UNIT_MAXHEALTH(unit)
    self:update(unit)
  end

  function headerBar:UNIT_FACTION(unit)
    self:update(unit)
  end

  function headerBar:UNIT_HEAL_PREDICTION(unit)
    self:UNIT_HEALTH_FREQUENT(unit)
  end

  function headerBar:UNIT_ABSORB_AMOUNT_CHANGED(unit)
    self:UNIT_MAXHEALTH(unit)
  end

  function headerBar:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(unit)
    self:UNIT_HEALTH_FREQUENT(unit)
  end

  function headerBar:UNIT_CONNECTION(unit)
    self:update(unit)
  end

  function headerBar:UNIT_PHASE(unit)
    self:update(unit)
  end

  headerBar:RegisterUnitEvent("UNIT_CONNECTION", unit)
  headerBar:RegisterUnitEvent("UNIT_PHASE", unit)
  headerBar:RegisterUnitEvent("UNIT_FACTION", unit)
  headerBar:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", unit)
  headerBar:RegisterUnitEvent("UNIT_HEALTH", unit)
  headerBar:RegisterUnitEvent("UNIT_HEAL_PREDICTION", unit)
  headerBar:RegisterUnitEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED", unit)
  headerBar:RegisterUnitEvent("UNIT_MAXHEALTH", unit)
  headerBar:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", unit)

  return headerBar
end

-- vim: tw=100 sw=2 et
