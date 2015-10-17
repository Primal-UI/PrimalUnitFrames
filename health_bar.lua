local addonName, addon = ...

setfenv(1, addon)

-- Prototype.
HealthBar = {

}

local healthTag = function(unit, healthMax, health, totalAbsorbs)
  if not _G.UnitIsConnected(unit) then
    return --[["|c" .. settings.offlineColor .. settings.strings.offline .. "|r"]]
  end

  local colorStr
  if --[[_G.UnitIsPlayer(unit)]] true then
    -- I don't like the blue UnitSelectionColor() returns when the unit is a player not active for PvP in some places.
    -- It's also used for NPCs sometimes.
    if _G.UnitIsEnemy("player", unit) then
      if _G.UnitCanAttack(unit, "player") then -- He can attack us.  Red.
        colorStr = "ffff0000"
      else -- He can't attack us.  Yellow.
        colorStr = "ffffff00"
      end
    else -- He's our friend.  Green.
      colorStr = "ff00ff00"
    end
  else
    local red, green, blue, alpha = _G.UnitSelectionColor(unit)
    -- http://wowprogramming.com/docs/api_types#colorString
    colorStr = _G.string.format("%02x%02x%02x%02x", alpha * 255, red * 255, green * 255, blue * 255)
  end

  local healthStr
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
      healthStr = healthStr .. " + " .. _G.string.format("%dm", _G.math.floor((totalAbsorbs + 500000) / 1000000))
    elseif totalAbsorbs > 0 then
      healthStr = healthStr .. " + " .. _G.string.format("%dk", _G.math.floor((totalAbsorbs + 500) / 1000))
    end
  end

  return "|c" .. colorStr .. healthStr .. "|r"
end

local percentHealthTag = function(unit, healthMax, health, totalAbsorbs)
  if not _G.UnitIsConnected(unit) then
    return
  end

  if _G.UnitIsDeadOrGhost(unit) then
    return
  end

  local color = "ff000000"
  local healthPercent = _G.math.floor(100 * health / healthMax + .5)

  return "|c" .. color .. healthPercent .. "%|r"
end

function createHealthBar(unit, mirror)
  local healthBar = _G.CreateFrame("Frame")

  healthBar.health = healthBar:CreateTexture()
  do
    local texture = healthBar.health
    local color = settings.colors.background
    texture:SetTexture(color.r, color.g, color.b, color.a)
    texture:SetPoint("TOP")
    texture:SetPoint("BOTTOM")
    if mirror then
      texture:SetPoint("RIGHT", healthBar)
    else
      texture:SetPoint("LEFT", healthBar)
    end
  end

  healthBar.healthMissing = healthBar:CreateTexture()
  do
    local texture = healthBar.healthMissing
    local color = settings.colors.health
    texture:SetTexture(color.r, color.g, color.b, color.a)
    texture:SetPoint("TOP")
    texture:SetPoint("BOTTOM")
    if mirror then
      texture:SetPoint("LEFT", healthBar)
    else
      texture:SetPoint("RIGHT", healthBar)
    end
  end

  healthBar.incomingAndAbsorbs = healthBar:CreateTexture()
  do
    local texture = healthBar.incomingAndAbsorbs
    texture:SetTexture("interface\\addons\\" .. addonName .. "\\media\\textures\\shield2", false, false)
    texture:SetHorizTile(false)
    texture:SetVertTile(false)
    texture:SetPoint("TOP")
    texture:SetPoint("BOTTOM")
    if mirror then
      texture:SetPoint("RIGHT", healthBar.health, "LEFT")
    else
      texture:SetPoint("LEFT", healthBar.health, "RIGHT")
    end
  end

  healthBar.absorbs = healthBar:CreateTexture()
  do
    -- I'm using SetTexCoord() to prevent the texture from appearing to move (it looks like only what part of the
    -- texture is shown changes, rather than the actual position of the texture changing). I couldn't get this to work
    -- when tiling the image, so I opted to modify it by repeating the original 32x32 pixel image 8 times horizontally.
    local texture = healthBar.absorbs
    texture:SetTexture("interface\\addons\\" .. addonName .. "\\media\\textures\\shield", false, false)
    texture:SetHorizTile(false)
    texture:SetVertTile(false)
    texture:SetPoint("TOP")
    texture:SetPoint("BOTTOM")
    if mirror then
      texture:SetPoint("RIGHT", healthBar.incomingAndAbsorbs, "LEFT")
    else
      texture:SetPoint("LEFT", healthBar.incomingAndAbsorbs, "RIGHT")
    end
  end

  healthBar.incomingHeals = healthBar:CreateTexture()
  do
    local texture = healthBar.incomingHeals
    local color = settings.colors.incomingHeals
    texture:SetTexture(color.r, color.g, color.b, color.a)
    texture:SetPoint("TOP")
    texture:SetPoint("BOTTOM")
    if mirror then
      texture:SetPoint("RIGHT", healthBar.incomingAndAbsorbs, "LEFT")
    else
      texture:SetPoint("LEFT", healthBar.incomingAndAbsorbs, "RIGHT")
    end
  end

  if not mirror then
    healthBar.fontString1 = healthBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
    healthBar.fontString1:SetPoint("LEFT", healthBar, "LEFT", settings.fontSpacing, 0)
    healthBar.fontString2 = healthBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")
    healthBar.fontString2:SetPoint("RIGHT", healthBar, "RIGHT", -settings.fontSpacing, 0)
  else
    healthBar.fontString1 = healthBar:CreateFontString(nil, nil, "NinjaKittyFontStringRight")
    healthBar.fontString1:SetPoint("RIGHT", healthBar, "RIGHT", -settings.fontSpacing, 0)
    healthBar.fontString2 = healthBar:CreateFontString(nil, nil, "NinjaKittyFontStringLeft")
    healthBar.fontString2:SetPoint("LEFT", healthBar, "LEFT", settings.fontSpacing, 0)
  end
  healthBar.fontString2:SetShadowColor(0, 0, 0, 0)
  healthBar.fontString2:SetShadowOffset(0, 0)

  healthBar:SetScript("OnSizeChanged", function(self, width, height)
    local availableWidth = width - 2 * settings.fontSpacing
    local leftTagWidth = _G.math.ceil(0.5 * availableWidth - 0.5) - settings.fontSpacing
    self.fontString1:SetWidth(leftTagWidth)
    self.fontString2:SetWidth(width - leftTagWidth - settings.fontSpacing)
  end)

  ----------------------------------------------------------------------------------------------------------------------
  healthBar:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  function healthBar:UNIT_HEALTH_FREQUENT(unit)
    local maxValue, healthMax, health, totalAbsorbs, incomingHeals, healAbsorbs
    if _G.UnitIsConnected(unit) then
      healthMax     = _G.UnitHealthMax(unit)
      health        = _G.UnitHealth(unit)
      totalAbsorbs  = _G.UnitGetTotalAbsorbs(unit)
      incomingHeals = _G.UnitGetIncomingHeals(unit) or 0
      healAbsorbs   = _G.UnitGetTotalHealAbsorbs(unit) or 0
    else
      healthMax     = self:GetWidth()
      health        = self:GetWidth()
      totalAbsorbs  = 0
      incomingHeals = 0
      healAbsorbs   = 0
    end

    -- Adding totalAbsorbs is a valid approach. It means the health and absorbs textures never have to be cropped, but
    -- their sizes are relative to the sum of maximum health and absorbs which can be misleading: 100k health and 100k
    -- absorbs (for example from Saved by the Light) would result in a wider missing health bar than 200k health.
    local maxValue = healthMax --[[+ totalAbsorbs]]

    -- UnitGetTotalHealAbsorbs() returns the amount of healing the unit will absorb without gaining health. Caused by
    -- abilities like Necrotic Strike. Update: Necrotic Strike was removed in Warlords of Draenor. I don't think there
    -- are heal absorbs in PvP; there might not be any heal absorbs in the game now.

    incomingHeals = _G.math.max(incomingHeals - healAbsorbs, 0)

    -- I don't think there's a dedicated event to inform us of a unit having died. Update: there is
    -- COMBAT_LOG_EVENT_UNFILTERED and its subevent UNIT_DIED.
    local color
    if _G.UnitIsDeadOrGhost(unit) then
      color = settings.colors.dead
    --[[
    elseif _G.UnitIsPlayer(unit) then
      local class = (_G.select(2, _G.UnitClassBase(unit)))
      color = class and settings.classColors[class] or settings.colors.health
    --]]
    else
      color = settings.colors.health
    end
    self.healthMissing:SetTexture(color.r, color.g, color.b, color.a)

    if _G.UnitIsDeadOrGhost(unit) then
      self.health:Hide()
      self.incomingAndAbsorbs:Hide()
      self.absorbs:Hide()
      self.incomingHeals:Hide()
      self.healthMissing:SetWidth(self:GetWidth())
      self.healthMissing:Show()
    else
      local healthWidth, absorbsWidth, incomingWidth, missingWidth

      healthWidth   = _G.math.floor(health * self:GetWidth() / maxValue + .5)
      absorbsWidth  = _G.math.floor(totalAbsorbs * self:GetWidth() / maxValue + .5)
      if healthWidth + absorbsWidth > self:GetWidth() then
        -- If the absorbs texture would extend out of the bar, it can take up to 5 pixels from the health texture.
        absorbsWidth = _G.math.max(self:GetWidth() - healthWidth, _G.math.min(absorbsWidth, 5))
        healthWidth  = _G.math.max(self:GetWidth() - absorbsWidth, _G.math.min(healthWidth, self:GetWidth() - 5))
      end
      incomingWidth = _G.math.floor(incomingHeals * self:GetWidth() / maxValue + .5)
      missingWidth  = self:GetWidth() - healthWidth - _G.math.max(absorbsWidth, incomingWidth)

      if healthWidth > 0 then
        self.health:SetWidth(healthWidth)
        self.health:Show()
      else
        -- Passing 0 to SetWidth() causes the region's width to be determined automatically according to its anchor
        -- points (wowprogramming.com/docs/widgets/Region/SetWidth). Passing negative numbers causes it to be hidden,
        -- but messes up regions anchored to it.
        self.health:Hide()
      end

      -- TODO: reduce boilerplate!

      local incomingAndAbsorbsWidth = _G.math.min(absorbsWidth, incomingWidth)
      if incomingAndAbsorbsWidth > 0 then
        self.incomingAndAbsorbs:SetWidth(incomingAndAbsorbsWidth)
        local left, right
        if mirror then
          left  = self.incomingAndAbsorbs:GetLeft() - self:GetLeft()
          right = left + incomingAndAbsorbsWidth
        else
          right = 256 + (self.incomingAndAbsorbs:GetRight() - self:GetRight())
          left  = right - incomingAndAbsorbsWidth
        end
        self.incomingAndAbsorbs:SetTexCoord(left / 256, right / 256, 0, self.absorbs:GetHeight() / 32)
        if not self.incomingAndAbsorbs:IsShown() then
          self.incomingAndAbsorbs:Show()
          if mirror then
            healthBar.absorbs:SetPoint("RIGHT", healthBar.incomingAndAbsorbs, "LEFT")
            healthBar.incomingHeals:SetPoint("RIGHT", healthBar.incomingAndAbsorbs, "LEFT")
          else
            healthBar.absorbs:SetPoint("LEFT", healthBar.incomingAndAbsorbs, "RIGHT")
            healthBar.incomingHeals:SetPoint("LEFT", healthBar.incomingAndAbsorbs, "RIGHT")
          end
        end
      elseif self.incomingAndAbsorbs:IsShown() then
        self.incomingAndAbsorbs:Hide()
        if mirror then
          healthBar.absorbs:SetPoint("RIGHT", healthBar.health, "LEFT")
          healthBar.incomingHeals:SetPoint("RIGHT", healthBar.health, "LEFT")
        else
          healthBar.absorbs:SetPoint("LEFT", healthBar.health, "RIGHT")
          healthBar.incomingHeals:SetPoint("LEFT", healthBar.health, "RIGHT")
        end
      end

      if absorbsWidth - incomingWidth > 0 then
        self.absorbs:SetWidth(absorbsWidth - incomingWidth)
        self.absorbs:Show()
        local left, right
        if mirror then
          left  = self.absorbs:GetLeft() - self:GetLeft()
          right = left + self.absorbs:GetWidth()
        else
          right = 256 + (self.absorbs:GetRight() - self:GetRight())
          left  = right - self.absorbs:GetWidth()
        end
        self.absorbs:SetTexCoord(left / 256, right / 256, 0, self.absorbs:GetHeight() / 32)
      else
        self.absorbs:Hide()
      end

      local incomingTextureWidth = _G.math.min(incomingWidth - absorbsWidth,
        self:GetWidth() - healthWidth - incomingAndAbsorbsWidth)
      -- TODO: there's a bug where self:GetWidth() is slightly to big and not an integer, causing us to enter the
      -- then-body of this if statement.
      if incomingTextureWidth > 0 then
        self.incomingHeals:SetWidth(incomingTextureWidth)
        self.incomingHeals:Show()
      else
        self.incomingHeals:Hide()
      end

      if missingWidth > 0 then
        self.healthMissing:SetWidth(missingWidth)
        self.healthMissing:Show()
      else
        self.healthMissing:Hide()
      end
    end

    if self:GetHeight() >= settings.fontSize then
      self.fontString1:SetText(healthTag(unit, healthMax, health, totalAbsorbs))
      self.fontString2:SetText(percentHealthTag(unit, healthMax, health, totalAbsorbs))
    end
  end

  healthBar.UNIT_HEALTH = healthBar.UNIT_HEALTH_FREQUENT

  function healthBar:update(unit)
    self:UNIT_MAXHEALTH(unit)
  end

  function healthBar:initialize(unit)
    -- ...
  end

  function healthBar:UNIT_MAXHEALTH(unit)
    self:UNIT_HEALTH_FREQUENT(unit)
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
  ----------------------------------------------------------------------------------------------------------------------

  return healthBar
end

-- vim: tw=120 sts=2 sw=2 et
