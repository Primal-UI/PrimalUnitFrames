setfenv(1, NinjaKittyUF)

function createUnitFrame(attributes)
  local unitFrame
  if _G.string.match(attributes.unit, "arena") then
    --unitFrame = _G.CreateFrame("Button", attributes.name, _G.UIParent,
      --"SecureUnitButtonTemplate,SecureHandlerAttributeTemplate")
    -- Mutually exclusive? I can't get the "_onstate-unitexists" snippet to execute when using both
    -- the SecureHandlerAttributeTemplate and SecureHandlerStateTemplate.
    --unitFrame = _G.CreateFrame("Button", attributes.name, _G.UIParent,
      --"SecureUnitButtonTemplate,SecureHandlerStateTemplate")
    unitFrame = _G.CreateFrame("Button", attributes.name, _G.UIParent, "SecureHandlerStateTemplate")
  else
    unitFrame = _G.CreateFrame("Button", attributes.name, _G.UIParent,
      "SecureUnitButtonTemplate")
    unitFrame:SetAttribute("*type1", "target")
    unitFrame:SetAttribute("*type2", "focus")
    unitFrame:SetAttribute("*type3", "togglemenu")
  end
  unitFrame:SetAttribute("unit", attributes.unit)

  unitFrame:SetFrameLevel(10)
  unitFrame:SetPoint(attributes.point, _G[attributes.relativeTo], attributes.relativePoint,
    attributes.xOffset, attributes.yOffset)
  unitFrame:SetWidth(attributes.width)
  --unitFrame:SetHitRectInsets(2, 2, 2, 2)

  unitFrame.unit = attributes.unit

  unitFrame:SetBackdrop(settings.unitFrameBackdrop)
  unitFrame:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)

  unitFrame:RegisterForClicks("AnyDown")

  --------------------------------------------------------------------------------------------------
  unitFrame.bars = {}

  local yOffset = -settings.insets.top
  local function createBar(i)
    local mirror = attributes.bars[i].mirror
    local bar = attributes.bars[i].create(attributes.unit, mirror, unitFrame)
    local height = attributes.bars[i].height
    bar:SetParent(unitFrame)
    bar:SetPoint("TOPLEFT", settings.spacing, yOffset)
    bar:SetPoint("TOPRIGHT", -settings.spacing, yOffset)
    bar:SetHeight(height)
    yOffset = yOffset - height
    return bar
  end

  unitFrame.bars[1] = createBar(1)

  for i = 2, #attributes.bars do
    local spacer = unitFrame:CreateTexture()
    spacer:SetTexture(0.0, 0.0, 0.0)
    spacer:SetPoint("TOPLEFT", settings.spacing, yOffset)
    spacer:SetPoint("TOPRIGHT", -settings.spacing, yOffset)
    spacer:SetHeight(1)
    yOffset = yOffset - settings.spacing
    unitFrame.bars[i] = createBar(i)
  end

  unitFrame:SetHeight(_G.math.abs(yOffset - settings.insets.bottom))
  --------------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------------------
  unitFrame:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, ...)
  end)

  -- Stuff we need to do when PLAYER_LOGIN fires.
  function unitFrame:initialize()
    for k, bar in _G.ipairs(self.bars) do
      if bar.initialize then bar:initialize(self.unit) end
    end
  end

  -- The UI is not locked down yet when PLAYER_LOGIN fires, _G.InCombatLockdown() is false.
  -- PLAYER_REGEN_DISABLED can be used to detect when the player is entering combat. IsInInstance()
  -- already returns useful information.
  function unitFrame:PLAYER_LOGIN()
    self:initialize()
  end
  unitFrame:RegisterEvent("PLAYER_LOGIN")

  -- Stuff we need to do when PLAYER_ENTERING_WORLD fires or when the unit changes.
  if _G.string.match(unitFrame.unit, "arena") then
    function unitFrame:update()
      for _, bar in _G.ipairs(self.bars) do
        if bar.update then bar:update(self.unit) end
      end
    end
  else
    function unitFrame:update()
      if _G.UnitExists(self.unit) then
        for _, bar in _G.ipairs(self.bars) do
          if bar.update then bar:update(self.unit) end
        end
      end
    end
  end

  function unitFrame:UNIT_NAME_UPDATE(unit)
    _G.assert(_G.UnitIsUnit(unit, self.unit))
    self:update()
  end
  unitFrame:RegisterUnitEvent("UNIT_NAME_UPDATE", unitFrame.unit)

  function unitFrame:UNIT_PHASE(unit)
    self:update()
  end
  unitFrame:RegisterUnitEvent("UNIT_PHASE", unitFrame.unit)

  function unitFrame:UNIT_CONNECTION(unit, hasConnected)
    self:update()
  end
  unitFrame:RegisterUnitEvent("UNIT_CONNECTION", unitFrame.unit)

  function unitFrame:COMBAT_LOG_EVENT_UNFILTERED(_, event, _, _, _, _, _, destGUID, _, _, _)
    if event == "UNIT_DIED" and _G.UnitGUID(self.unit) == destGUID then
      self:update()
    end
  end
  unitFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

  if _G.string.match(unitFrame.unit, "arena") then
    function unitFrame:PLAYER_ENTERING_WORLD()
      _G.assert(not _G.InCombatLockdown())
      local _, instanceType = _G.IsInInstance()

      -- http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/SecureStateDriver.lua
      if _G.UnitWatchRegistered(unitFrame) then
        _G.UnregisterUnitWatch(unitFrame)
      end
      if instanceType == "arena" then
        -- The "state-unitexists" attribute will be set to a boolean value denoting whether the unit
        -- exists.
        _G.RegisterUnitWatch(unitFrame, true)
      elseif instanceType == "pvp" then
        _G.RegisterUnitWatch(unitFrame)
      end

      if instanceType ~= "arena" then
        self:Hide()
      elseif _G.UnitExists(self.unit) then
        self:update()
      end
    end
  else
    function unitFrame:PLAYER_ENTERING_WORLD()
      if _G.UnitExists(self.unit) then
        self:update()
      end
    end
  end
  unitFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

  if not _G.string.match(unitFrame.unit, "arena") and unitFrame.unit ~= "player" then
    _G.RegisterUnitWatch(unitFrame)
  end

  --------------------------------------------------------------------------------------------------
  if unitFrame.unit == "player" then
    -- ...

  elseif unitFrame.unit == "target" then
    function unitFrame:PLAYER_TARGET_CHANGED(cause)
      self:update()
    end
    unitFrame:RegisterEvent("PLAYER_TARGET_CHANGED") -- This is faster than UNIT_TARGET.

  elseif unitFrame.unit == "focus" then
    function unitFrame:PLAYER_FOCUS_CHANGED(cause)
      self:update()
    end
    unitFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")

  elseif unitFrame.unit == "vehicle" then
    function unitFrame:UNIT_ENTERED_VEHICLE(unit)
      if unit == "player" then -- I don't know why we need to check this, but apparently we do.
        self:update()
      end
    end
    unitFrame:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")

  elseif _G.string.match(unitFrame.unit, "arena") then
    unitFrame:SetAttribute("_onstate-unitexists", [[ -- arguments: self, stateid, newstate
      --print("_onstate-unitexists", self, stateid, newstate)
      if newstate then
        self:CallMethod("update")
        if not self:IsShown() then self:Show() end
      end
    ]])
    --[=[
    unitFrame:SetAttribute("_onattributechanged", [[ -- arguments: self, name, value
      --print("_onattributechanged", self, name, value)
      if name == "state-unitexists" then
        -- ...
      end
    ]])
    --]=]
    function unitFrame:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
      --if _G.InCombatLockdown() then return end
      local specID
      for i = 1, _G.MAX_ARENA_ENEMIES do
        if unitFrame.unit == "arena" .. i then
          specID = _G.GetArenaOpponentSpec(i)
          break
        end
      end
      if specID and specID > 0 then
        local _, name, _, _, _, _, class = _G.GetSpecializationInfoByID(specID)
        if not self:IsShown() then
          self:Show()
        else
          self:update()
        end
      end
    end
    unitFrame:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
    function unitFrame:ARENA_OPPONENT_UPDATE(unit, eventType)
      if _G.UnitIsUnit(unit, self.unit) then
        _G.print(unit, eventType)
      end
      if _G.UnitExists(unit) then
        self:update()
      end
      if not _G.InCombatLockdown() then
        if _G.UnitIsUnit(unit, self.unit) then
          if eventType == "cleared" then
            self:Hide()
          end
        end
      end
    end
    unitFrame:RegisterUnitEvent("ARENA_OPPONENT_UPDATE", unitFrame.unit)

  elseif _G.string.match(unitFrame.unit, "party") then
    function unitFrame:GROUP_ROSTER_UPDATE()
      if _G.UnitExists(self.unit) then
        self:update()
      end
    end
    unitFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

    function unitFrame:PARTY_MEMBERS_CHANGED()
      self:update()
    end
    unitFrame:RegisterEvent("PARTY_MEMBER_ENABLE")

    function unitFrame:PARTY_MEMBER_ENABLE(id)
      if _G.string.match(self.unit, id) then
        self:update()
      end
    end
    unitFrame:RegisterEvent("PARTY_MEMBER_ENABLE")

    function unitFrame:PARTY_MEMBER_DISABLE(id)
      if _G.string.match(self.unit, id) then
        self:update()
      end
    end
    unitFrame:RegisterEvent("PARTY_MEMBER_DISABLE")

    -- http://wowprogramming.com/utils/xmlbrowser/test/FrameXML/PartyMemberFrame.lua
    function unitFrame:UNIT_OTHER_PARTY_CHANGED(unit)
      if unit == self.unit then
        -- ...
      end
    end
    unitFrame:RegisterUnitEvent("PARTY_MEMBER_DISABLE", unitFrame.unit)

  elseif _G.string.match(unitFrame.unit, "raid") then
    -- Not implemented.
  end
  --------------------------------------------------------------------------------------------------

  if not unitFrame:HasScript("OnShow") then
    unitFrame:SetScript("OnShow", function(self) end)
  end
  unitFrame:HookScript("OnShow", function(self)
    self:update()
  end)

  unitFrame:SetScript("OnEnter", function(self, motion)
    self:SetBackdropBorderColor(1.0, 1.0, 1.0, 1.0)
    -- See "http://www.wowwiki.com/Talk:UIOBJECT_GameTooltip".
    _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
    _G.GameTooltip:SetUnit(attributes.unit)
    -- Took these lines (more or less) from blizzard's "UnitFrame_UpdateTooltip". See
    -- "http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitFrame.lua".
    local r, g, b = _G.GameTooltip_UnitColor(attributes.unit)
    _G.GameTooltipTextLeft1:SetTextColor(r, g, b)
  end)

  unitFrame:SetScript("OnLeave", function(self, motion)
    self:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
    _G.GameTooltip:FadeOut()
  end)

  return unitFrame
end

-- vim: tw=100 sw=2 et
