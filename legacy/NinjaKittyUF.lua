setfenv(1, NinjaKittyUF)

string, math = _G.string, _G.math
UIParent = _G.UIParent
NinjaKittyUF = _G.NinjaKittyUF
LibStub = _G.LibStub
CreateFrame = _G.CreateFrame

barTexture = [[Interface\AddOns\ShadowedUnitFrames\media\textures\smooth]]
defaultFont = _G.CreateFont("NKUFDefaultFont")

defaultFont:SetFont([[Interface\AddOns\NinjaKittyMedia\fonts\Ubuntu-M.ttf]], 11, "")
defaultFont:SetShadowColor(0, 0, 0, 1)
defaultFont:SetShadowOffset(1, -1)

local playerFrame =
  CreateFrame("Button", "NKUFPlayerFrame", UIParent, "SecureUnitButtonTemplate")
playerFrame:SetPoint("BOTTOMRIGHT", nil, "BOTTOM", -272, 288)
playerFrame:SetSize(224, 82)
playerFrame:SetHitRectInsets(2, 2, 2, 2)

local vehicleFrame =
  CreateFrame("Button", "NKUFVehicleFrame", UIParent, "SecureUnitButtonTemplate")
vehicleFrame:SetPoint("BOTTOM", playerFrame, "TOP", 0, 0)
vehicleFrame:SetSize(224, 50) -- 2 + 1 + 25 + 1 + 18 + 1 + 2
vehicleFrame:SetHitRectInsets(2, 2, 2, 2)

playerFrame:SetScript("OnEnter", function(self, motion)
  -- See "http://www.wowwiki.com/Talk:UIOBJECT_GameTooltip".
  _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
  _G.GameTooltip:SetUnit("player")
  -- Took these lines (more or less) from blizzard's "UnitFrame_UpdateTooltip". See
  -- "http://wowprogramming.com/utils/xmlbrowser/live/FrameXML/UnitFrame.lua".
  local r, g, b = _G.GameTooltip_UnitColor("player")
  _G.GameTooltipTextLeft1:SetTextColor(r, g, b)
end)

playerFrame:SetScript("OnLeave", function(self, motion)
  _G.GameTooltip:FadeOut()
end)

vehicleFrame:SetScript("OnEnter", function(self, motion)
  _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
  _G.GameTooltip:SetUnit("vehicle")
  local r, g, b = _G.GameTooltip_UnitColor("vehicle")
  _G.GameTooltipTextLeft1:SetTextColor(r, g, b)
end)

vehicleFrame:SetScript("OnLeave", function(self, motion)
  _G.GameTooltip:FadeOut()
end)

-- See wowprogramming.com/docs/widgets/Frame/SetBackdrop.
local unitFrameBackdrop = {
  -- Got the path here: us.battle.net/wow/en/forum/topic/4254461130.
  bgFile = [[Interface\\ChatFrame\\ChatFrameBackground]], 
  tile = false,
  insets = { left = 2, right = 2, top = 2, bottom = 2 }
}
playerFrame:SetBackdrop(unitFrameBackdrop)
playerFrame:SetBackdropColor(0, 0, 0, 1)

vehicleFrame:SetBackdrop(unitFrameBackdrop)
vehicleFrame:SetBackdropColor(0, 0, 0, 1)

local pHealthBar = CreateFrame("StatusBar", "NKUFPlayerHealthBar", playerFrame)
local pIncHealsBar= CreateFrame("StatusBar", "NKUFPlayerIncomingHealsBar", playerFrame)
local pAbsorbsBar= CreateFrame("StatusBar", "NKUFPlayerAbsorbsBar", playerFrame)
local pManaBar = CreateFrame("StatusBar", "NKUFPlayerEnergyBar", playerFrame)
local gCDBar = CreateFrame("StatusBar", "NKUFGCDBar", playerFrame)
local pEnergyBar = CreateFrame("StatusBar", "NKUFPlayerEnergyBar", playerFrame)
local pRageBar = CreateFrame("StatusBar", "NKUFPlayerEnergyBar", playerFrame)

local vHealthBar = CreateFrame("StatusBar", "NKUFVehicleHealthBar", vehicleFrame)
local vPowerBar = CreateFrame("StatusBar", "NKUFVehiclePowerBar", vehicleFrame)

local pPowerBarAlt = CreateFrame("StatusBar", "NKUFPlayerPowerBarAlt", UIParent)

-- < Player Health Bar > -------------------------------------------------------
--------------------------------------------------------------------------------
pHealthBar:SetPoint("TOPLEFT", playerFrame, "TOPLEFT", 3, -3)
pHealthBar:SetPoint("RIGHT", playerFrame, "RIGHT", -3, 0)
pHealthBar:SetHeight(25)
pHealthBar:SetFrameLevel(5)

local pHBackground = pHealthBar:CreateTexture(nil, "BACKGROUND")
pHBackground:SetAllPoints(pHealthBar)
pHBackground:SetTexture(barTexture)

pHealthBar:SetStatusBarTexture(barTexture)

local pHFontString = pHealthBar:CreateFontString()
pHFontString:SetPoint("LEFT", pHealthBar, "LEFT", 3, 0)
pHFontString:SetPoint("RIGHT", pHealthBar, "RIGHT", -3, 0)
pHFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Player Health Bar > ------------------------------------------------------

-- < Incoming Heals Bar > ------------------------------------------------------
--------------------------------------------------------------------------------
pIncHealsBar:SetAllPoints(pHealthBar)
pIncHealsBar:SetStatusBarTexture(barTexture)
pIncHealsBar:SetFrameLevel(4)
--------------------------------------------------------------------------------
-- </ Incoming Heals Bar > -----------------------------------------------------

-- < Absorbs Bar > -------------------------------------------------------------
--------------------------------------------------------------------------------
pAbsorbsBar:SetAllPoints(pHealthBar)
pAbsorbsBar:SetStatusBarTexture(barTexture)
pAbsorbsBar:SetFrameLevel(pIncHealsBar:GetFrameLevel() - 1)
--------------------------------------------------------------------------------
-- </ Absorbs Bar > ------------------------------------------------------------

-- < Player Mana Bar > ---------------------------------------------------------
--------------------------------------------------------------------------------
pManaBar:SetPoint("TOPLEFT", pHealthBar, "BOTTOMLEFT", 0, -1)
pManaBar:SetPoint("RIGHT", pHealthBar, "RIGHT", 0, 0)

local pMBackground = pManaBar:CreateTexture(nil, "BACKGROUND")
pMBackground:SetAllPoints(pManaBar)
pMBackground:SetTexture(barTexture)

pManaBar:SetStatusBarTexture(barTexture)

local pMFontString = pManaBar:CreateFontString()
pMFontString:SetPoint("LEFT", pManaBar, "LEFT", 3, 0)
pMFontString:SetPoint("RIGHT", pManaBar, "RIGHT", -3, 0)
pMFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Player Mana Bar > --------------------------------------------------------

-- < GCD Bar > -----------------------------------------------------------------
--------------------------------------------------------------------------------
gCDBar:SetPoint("TOPLEFT", pManaBar, "BOTTOMLEFT", 0, -1)
gCDBar:SetPoint("RIGHT", pManaBar, "RIGHT", 0, 0)
gCDBar:SetHeight(7)

local gCDBackground = gCDBar:CreateTexture(nil, "BACKGROUND")
gCDBackground:SetAllPoints(gCDBar)
gCDBackground:SetTexture(barTexture)

gCDBar:SetStatusBarTexture(barTexture)

do
  gCDBar:SetMinMaxValues(0, 1)
  --gCDBar:SetReverseFill(true)
  gCDBar:SetScript("OnUpdate", function()
    --local cooldown = _G.GetSpellBaseCooldown(52610)
    local start, duration = _G.GetSpellCooldown(52610)
    if duration ~= 0 and duration ~= _G.select(2, gCDBar:GetMinMaxValues()) then
      gCDBar:SetMinMaxValues(0, duration)
    end
    local cooldown = duration - (_G.GetTime() - start)
    --NinjaKittyUF:Print(cooldown)
    if cooldown >= 0 then
      gCDBar:SetValue(cooldown)
    else
      gCDBar:SetValue(0)
    end
  end)
end
--------------------------------------------------------------------------------
-- </ GCD Bar > ----------------------------------------------------------------

-- < Energy Bar > --------------------------------------------------------------
--------------------------------------------------------------------------------
pEnergyBar:SetPoint("TOPLEFT", gCDBar, "BOTTOMLEFT", 0, -1)
pEnergyBar:SetPoint("RIGHT", gCDBar, "RIGHT", 0, 0)

local pEBackground = pEnergyBar:CreateTexture(nil, "BACKGROUND")
pEBackground:SetAllPoints(pEnergyBar)
pEBackground:SetTexture(barTexture)

pEnergyBar:SetStatusBarTexture(barTexture)

local pEFontString = pEnergyBar:CreateFontString()
pEFontString:SetPoint("LEFT", pEnergyBar, "LEFT", 3, 0)
pEFontString:SetPoint("RIGHT", pEnergyBar, "RIGHT", -3, 0)
pEFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Energy Bar > -------------------------------------------------------------

-- < Rage Bar > ----------------------------------------------------------------
--------------------------------------------------------------------------------
pRageBar:SetPoint("TOPLEFT", pManaBar, "BOTTOMLEFT", 0, -1)
pRageBar:SetPoint("RIGHT", pManaBar, "RIGHT", 0, 0)

local pRBackground = pRageBar:CreateTexture(nil, "BACKGROUND")
pRBackground:SetAllPoints(pRageBar)
pRBackground:SetTexture(barTexture)

pRageBar:SetStatusBarTexture(barTexture)

local pRFontString = pRageBar:CreateFontString()
pRFontString:SetPoint("LEFT", pRageBar, "LEFT", 3, 0)
pRFontString:SetPoint("RIGHT", pRageBar, "RIGHT", -3, 0)
pRFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Rage Bar > ---------------------------------------------------------------

-- < Vehicle Health Bar > ------------------------------------------------------
--------------------------------------------------------------------------------
vHealthBar:SetPoint("TOPLEFT", vehicleFrame, "TOPLEFT", 3, -3)
vHealthBar:SetPoint("RIGHT", vehicleFrame, "RIGHT", -3, 0)
vHealthBar:SetHeight(25)

local vHBackground = vHealthBar:CreateTexture(nil, "BACKGROUND")
vHBackground:SetAllPoints(vHealthBar)
vHBackground:SetTexture(barTexture)

vHealthBar:SetStatusBarTexture(barTexture)

local vHFontString = vHealthBar:CreateFontString()
vHFontString:SetPoint("LEFT", vHealthBar, "LEFT", 3, 0)
vHFontString:SetPoint("RIGHT", vHealthBar, "RIGHT", -3, 0)
vHFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Vehicle Health Bar > -----------------------------------------------------

-- < Vehicle Power Bar > -------------------------------------------------------
--------------------------------------------------------------------------------
vPowerBar:SetPoint("TOPLEFT", vHealthBar, "BOTTOMLEFT", 0, -1)
vPowerBar:SetPoint("RIGHT", vHealthBar, "RIGHT", 0, 0)
vPowerBar:SetHeight(18)

local vPBackground = vPowerBar:CreateTexture(nil, "BACKGROUND")
vPBackground:SetAllPoints(vPowerBar)
vPBackground:SetTexture(barTexture)

vPowerBar:SetStatusBarTexture(barTexture)

local vPFontString = vPowerBar:CreateFontString()
vPFontString:SetPoint("LEFT", vPowerBar, "LEFT", 3, 0)
vPFontString:SetPoint("RIGHT", vPowerBar, "RIGHT", -3, 0)
vPFontString:SetFontObject(defaultFont)
--------------------------------------------------------------------------------
-- </ Vehicle Power Bar > ------------------------------------------------------

-- < Player Alternate Power Bar > ----------------------------------------------
--------------------------------------------------------------------------------
-- I've taken some ideas from:
-- "https://github.com/haste/oUF/blob/master/elements/altpowerbar.lua" and
-- "http://www.curse.com/addons/wow/customplayerpowerbaralt".
pPowerBarAlt:SetPoint("LEFT", pHealthBar, "LEFT", 0, 0)
pPowerBarAlt:SetPoint("RIGHT", pHealthBar, "RIGHT", 0, 0)
pPowerBarAlt:SetHeight(18)

pPBABackdrop = pPowerBarAlt:CreateTexture(nil, "BACKGROUND")
pPBABackdrop:SetTexture(0, 0, 0, 1) -- Black and fully opaque.
pPBABackdrop:SetPoint("TOPLEFT", pPowerBarAlt, "TOPLEFT", -1, 1)
pPBABackdrop:SetPoint("BOTTOMRIGHT", pPowerBarAlt, "BOTTOMRIGHT", 1, -1)

local pPBABackground = pPowerBarAlt:CreateTexture(nil, "BACKGROUND")
pPBABackground:SetAllPoints(pPowerBarAlt)
pPBABackground:SetTexture(barTexture)

pPowerBarAlt:SetStatusBarTexture(barTexture)

local pPBALeftFontString = pPowerBarAlt:CreateFontString()
pPBALeftFontString:SetPoint("LEFT", pPowerBarAlt, "LEFT", 3, 0)
-- Set the width to 75% of the available space: 224 pixels with the bar starting
-- after 3 pixels at each side and each font string having another 3 unused
-- pixels to its left and right: 0.75 * (224 - 3*6) = (3/4) * 206 = 3*51  = 153.
pPBALeftFontString:SetWidth(153)
pPBALeftFontString:SetFontObject(defaultFont)
pPBALeftFontString:SetJustifyH("LEFT")

local pPBARightFontString = pPowerBarAlt:CreateFontString()
pPBARightFontString:SetPoint("LEFT", pPBALeftFontString, "RIGHT", 3, 0)
pPBARightFontString:SetPoint("RIGHT", pPowerBarAlt, "RIGHT", -3, 0)
pPBARightFontString:SetFontObject(defaultFont)
pPBARightFontString:SetJustifyH("RIGHT")

pPowerBarAlt:SetScript("OnEnter", function(self, motion)
  --if not self:IsVisible() then return end
  local _, _, _, _, _, _, _, _, _, powerName, powerTooltip =
    _G.UnitAlternatePowerInfo("player")

  if powerName and powerTooltip then
    --_G.GameTooltip:SetOwner(self, "ANCHOR_NONE")
    --_G.GameTooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMRIGHT", 0, 0)
    _G.GameTooltip_SetDefaultAnchor(_G.GameTooltip, _G.WorldFrame)
    _G.GameTooltip:AddLine(powerName, 1, 1, 1, false)
    _G.GameTooltip:AddLine(powerTooltip, nil, nil, nil, true)
    _G.GameTooltip:Show()
  end
end)

pPowerBarAlt:SetScript("OnLeave", function(self, motion)
  --NinjaKittyUF:Print(self, motion)
  --_G.GameTooltip:FadeOut()
  _G.GameTooltip:Hide()
end)
--------------------------------------------------------------------------------
-- </ Player Alternate Power Bar > ---------------------------------------------

local handlerFrame = CreateFrame("Frame")

-- http://www.wowinterface.com/forums/showthread.php?p=267998
handlerFrame:SetScript("OnEvent", function(self, event, ...)
  return self[event] and self[event](self, ...)
end)

function handlerFrame:UNIT_MAXHEALTH(unitID)
  if not unitID then return end
  local healthMax = _G.UnitHealthMax(unitID)
  if unitID == "player" then
    pHealthBar:SetMinMaxValues(0, healthMax)
    pIncHealsBar:SetMinMaxValues(0, healthMax)
    pAbsorbsBar:SetMinMaxValues(0, healthMax)
  elseif unitID == "vehicle" then
    vHealthBar:SetMinMaxValues(0, healthMax)
  end
end

function handlerFrame:UNIT_HEALTH_FREQUENT(unitID)
  if not unitID then return end
  local health = _G.UnitHealth(unitID)
  if unitID == "player" then
    local incHeals = _G.UnitGetIncomingHeals(unitID)
    local absobs = _G.UnitGetTotalAbsorbs(unitID)
    pHealthBar:SetValue(health)
    pHFontString:SetText(_G.UnitIsDead(unitID) and "Dead" or _G.UnitIsGhost(unitID) and "Ghost" or
      health > 999 and string.format("%dk", math.floor((health + 500) / 1000)) or "<1k")
    pIncHealsBar:SetValue(health + incHeals)
    pAbsorbsBar:SetValue(health + incHeals + absobs)
  elseif unitID == "vehicle" then
    vHealthBar:SetValue(health)
    vHFontString:SetText(_G.UnitIsDead(unitID) or
      string.format("%dk", math.floor((health + 500) / 1000)))
  end
end

-- Do I get even more frequent updates by registering for UNIT_POWER as well?
function handlerFrame:UNIT_POWER(...)
  --NinjaKittyUF:Print("UNIT_POWER", ...)
  --self:UNIT_POWER_FREQUENT(...)
end

function handlerFrame:UNIT_POWER_FREQUENT(unitID, powerType)
  --NinjaKittyUF:Print("unitID == " .. unitID .. " and powerType == " .. powerType)
  if not unitID then return end
  if unitID == "player" and powerType then
    if powerType == "ALTERNATE" then
      local alternatePower = _G.UnitPower(unitID, _G.SPELL_POWER_ALTERNATE_POWER)
      pPowerBarAlt:SetValue(alternatePower)
      pPBARightFontString:SetText(alternatePower)
    elseif _G.UnitIsDeadOrGhost(unitID) then
      pManaBar:SetValue(0)
      pRageBar:SetValue(0)
      pEnergyBar:SetValue(0)
      pMFontString:SetText("0")
    elseif powerType == "MANA" then
      local mana = _G.UnitPower(unitID, _G.SPELL_POWER_MANA)
      pManaBar:SetValue(mana)
      pMFontString:SetText(mana > 999 and string.format("%dk", math.floor((mana + 500) / 1000)) or
        "<1k")
    elseif powerType == "RAGE" then
      local rage = _G.UnitPower(unitID, _G.SPELL_POWER_RAGE)
      pRageBar:SetValue(rage)
      pRFontString:SetText(rage)
    elseif powerType == "ENERGY" then
      local energy = _G.UnitPower(unitID, _G.SPELL_POWER_ENERGY)
      pEnergyBar:SetValue(energy)
      pEFontString:SetText(energy)
    end
  elseif unitID == "vehicle" then
    --local powerIndex, powerTypeString = _G.UnitPowerType("vehicle")
    --if powerType == powerTypeString then
      local power = _G.UnitPower(unitID)
      vPowerBar:SetValue(power)
      vPFontString:SetText(power)
    --end
  end
end

-- Doesn't look like we get to know the power type.
function handlerFrame:UNIT_MAXPOWER(unitID)
  if not unitID then return end
  if unitID == "player" then
    pEnergyBar:SetMinMaxValues(0, _G.UnitPowerMax(unitID, _G.SPELL_POWER_ENERGY))
    pManaBar:SetMinMaxValues(0, _G.UnitPowerMax(unitID, _G.SPELL_POWER_MANA))
    pRageBar:SetMinMaxValues(0, _G.UnitPowerMax(unitID, _G.SPELL_POWER_RAGE))
    self:UNIT_POWER_BAR_SHOW("player")
  elseif unitID == "vehicle" then
    -- ...
  end
end

function handlerFrame:UNIT_DISPLAYPOWER(unitID)
  if not unitID or unitID ~= "player" then return end
  if _G.UnitPowerType("player") == 0 then -- Are we using mana?
    pManaBar:SetPoint("TOPLEFT", pHealthBar, "BOTTOMLEFT", 0, -1)
    pManaBar:SetPoint("RIGHT", pHealthBar, "RIGHT", 0, 0)
    pEnergyBar:SetPoint("TOPLEFT", pManaBar, "BOTTOMLEFT", 0, -1)
    pEnergyBar:SetPoint("RIGHT", pManaBar, "RIGHT", 0, 0)
    pRageBar:SetPoint("TOPLEFT", pEnergyBar, "BOTTOMLEFT", 0, -1)
    pRageBar:SetPoint("RIGHT", pEnergyBar, "RIGHT", 0, 0)
    gCDBar:SetPoint("TOPLEFT", pRageBar, "BOTTOMLEFT", 0, -1)
    gCDBar:SetPoint("RIGHT", pRageBar, "RIGHT", 0, -1)
    pManaBar:SetHeight(18)
    pEnergyBar:SetHeight(11)
    pRageBar:SetHeight(11)
    pMFontString:Show()
    pRageBar:Hide()
    pEFontString:Hide()
  elseif _G.UnitPowerType("player") == 1 then -- Are we using rage?
    pRageBar:SetPoint("TOPLEFT", pHealthBar, "BOTTOMLEFT", 0, -1)
    pRageBar:SetPoint("RIGHT", pHealthBar, "RIGHT", 0, 0)
    pEnergyBar:SetPoint("TOPLEFT", pRageBar, "BOTTOMLEFT", 0, -1)
    pEnergyBar:SetPoint("RIGHT", pRageBar, "RIGHT", 0, 0)
    pManaBar:SetPoint("TOPLEFT", pEnergyBar, "BOTTOMLEFT", 0, -1)
    pManaBar:SetPoint("RIGHT", pEnergyBar, "RIGHT", 0, 0)
    gCDBar:SetPoint("TOPLEFT", pManaBar, "BOTTOMLEFT", 0, -1)
    gCDBar:SetPoint("RIGHT", pManaBar, "RIGHT", 0, -1)
    pRageBar:SetHeight(18)
    pEnergyBar:SetHeight(11)
    pManaBar:SetHeight(11)
    pRageBar:Show()
    pEFontString:Hide()
    pMFontString:Hide()
  elseif _G.UnitPowerType("player") == 3 then -- Are we using energy?
    pEnergyBar:SetPoint("TOPLEFT", pHealthBar, "BOTTOMLEFT", 0, -1)
    pEnergyBar:SetPoint("RIGHT", pHealthBar, "RIGHT", 0, 0)
    pManaBar:SetPoint("TOPLEFT", pEnergyBar, "BOTTOMLEFT", 0, -1)
    pManaBar:SetPoint("RIGHT", pEnergyBar, "RIGHT", 0, 0)
    pRageBar:SetPoint("TOPLEFT", pManaBar, "BOTTOMLEFT", 0, -1)
    pRageBar:SetPoint("RIGHT", pManaBar, "RIGHT", 0, 0)
    gCDBar:SetPoint("TOPLEFT", pRageBar, "BOTTOMLEFT", 0, -1)
    gCDBar:SetPoint("RIGHT", pRageBar, "RIGHT", 0, -1)
    pEnergyBar:SetHeight(18)
    pManaBar:SetHeight(11)
    pRageBar:SetHeight(11)
    pEFontString:Show()
    pMFontString:Hide()
    pRageBar:Hide()
  end
end

function handlerFrame:UNIT_HEAL_PREDICTION(unitID)
  local health = _G.UnitHealth(unitID)
  local incHeals = _G.UnitGetIncomingHeals(unitID)
  local absobs = _G.UnitGetTotalAbsorbs(unitID)
  pIncHealsBar:SetValue(health + incHeals)
  pAbsorbsBar:SetValue(health + incHeals + absobs)
end

function handlerFrame:UNIT_ABSORB_AMOUNT_CHANGED(unitID)
  local health = _G.UnitHealth(unitID)
  local incHeals = _G.UnitGetIncomingHeals(unitID)
  local absobs = _G.UnitGetTotalAbsorbs(unitID)
  pAbsorbsBar:SetValue(health + incHeals + absobs)
end

function handlerFrame:UNIT_ENTERED_VEHICLE(...)
  if _G.UnitHasVehicleUI("player") then
  end
end

function handlerFrame:UNIT_EXITED_VEHICLE(...)
  if not _G.UnitHasVehicleUI("player") then
  end
end

function handlerFrame:UNIT_POWER_BAR_SHOW(...)
  --NinjaKittyUF:Print(...)
  --NinjaKittyUF:Print(_G.UnitAlternatePowerInfo("player"))
  --NinjaKittyUF:Print(_G.UnitAlternatePowerTextureInfo("player"), 2)

  local barType, minAltPower, _, _, _, _, _, _, _, powerName, powerTooltip =
    _G.UnitAlternatePowerInfo("player")
  local maxAltPower = _G.UnitPowerMax("player", _G.SPELL_POWER_ALTERNATE_POWER)

  if barType and minAltPower and maxAltPower then
    pPowerBarAlt:SetMinMaxValues(minAltPower, maxAltPower)
    pPBALeftFontString:SetText(powerName or "nil")
    self:UNIT_POWER_FREQUENT("player", "ALTERNATE")
    pPowerBarAlt:Show()
  end
end

function handlerFrame:UNIT_POWER_BAR_HIDE(...)
  --NinjaKittyUF:Print(...)
  pPowerBarAlt:Hide()
end

function handlerFrame:PLAYER_ALIVE()
  --NinjaKittyUF:Print("PLAYER_ALIVE")
  handlerFrame:UNIT_POWER_FREQUENT("player", "MANA")
end

function handlerFrame:PLAYER_UNGHOST()
  --NinjaKittyUF:Print("PLAYER_UNGHOST")
  handlerFrame:UNIT_POWER_FREQUENT("player", "MANA")
end

playerFrame:SetAttribute("unit", "player")
playerFrame:SetAttribute("*type1", "target")
playerFrame:SetAttribute("*type2", "focus")
playerFrame:SetAttribute("*type3", "togglemenu")

vehicleFrame:SetAttribute("unit", "vehicle")
vehicleFrame:SetAttribute("*type1", "target")
vehicleFrame:SetAttribute("*type2", "focus")
vehicleFrame:SetAttribute("*type3", "togglemenu")

local vehicleStateHandler =
  CreateFrame("Frame", nil, nil, "SecureHandlerStateTemplate")

function vehicleStateHandler:onVehicleState(newstate)
  if newstate == "vehicle" then
    pPowerBarAlt:SetPoint("BOTTOM", vehicleFrame, "TOP", 0, 3)

    local powerType, powerTypeString = _G.UnitPowerType("vehicle")
    local powerMax = powerType and _G.UnitPowerMax("vehicle", powerType) or nil
    if powerType and powerMax and powerMax ~= 0 then
      local powerColor = _G.ShadowUF.db.profile.powerColors[powerTypeString]
      vPowerBar:SetStatusBarColor(powerColor.r, powerColor.g, powerColor.b)
      vPBackground:SetVertexColor(powerColor.r, powerColor.g, powerColor.b, 0.25)
      local power = _G.UnitPower("vehicle", powerType)
      vPowerBar:SetMinMaxValues(0, powerMax)
      handlerFrame:UNIT_POWER_FREQUENT("vehicle")
      vPowerBar:Show()

      --NinjaKittyUF:Print(power .. ", " .. powerMax)
      --NinjaKittyUF:Print(powerTypeString)
      --NinjaKittyUF:Print(powerColor.r, powerColor.g, powerColor.b)
    else
      vPowerBar:Hide()
    end

    handlerFrame:UNIT_MAXHEALTH("vehicle")
    handlerFrame:UNIT_HEALTH_FREQUENT("vehicle")
  elseif newstate == "novehicle" then
    pPowerBarAlt:SetPoint("BOTTOM", playerFrame, "TOP", 0, 3)
  end
end

vehicleStateHandler:SetFrameRef("playerFrame", playerFrame);
vehicleStateHandler:SetFrameRef("vehicleFrame", vehicleFrame);

-- I think I can call UnitHasVehicleUI() in the restricted environment.
vehicleStateHandler:SetAttribute("_onstate-vehiclestate", [[
  self:CallMethod("onVehicleState", newstate)
  --if newstate == "vehicle" and UnitHasVehicleUI("player") then
  if newstate == "vehicle" then
    --self:GetFrameRef("playerFrame"):SetAttribute("unit", "vehicle")
    self:GetFrameRef("vehicleFrame"):Show()
  elseif newstate == "novehicle" then
    --self:GetFrameRef("playerFrame"):SetAttribute("unit", "player")
    self:GetFrameRef("vehicleFrame"):Hide()
  end
]])

-- Called by AceAddon on ADDON_LOADED?
-- See: wowace.com/addons/ace3/pages/getting-started/#w-standard-methods
function NinjaKittyUF:OnInitialize()
  --NinjaKittyUF:Print("OnInitialize() called.")
  --NinjaKittyUF:Print(playerFrame:GetScale())
  --NinjaKittyUF:Print(playerFrame:GetEffectiveScale())
end

function handlerFrame:ADDON_LOADED(name)
  if not _G.ShadowedUFDB or not _G.ShadowUF then return end
  -- Saved variables of "Shadowed Unit Frames" are available and "ShadowedUnitFrames.lua" is loaded.
  if not _G.ShadowUF.db then
  -- ShadowUF:OnInitialize() wasn't called yet. Nothing we can do about it, since it's called on
  -- PLAYER_LOGIN :/
    --return
  end

  NinjaKittyUF:Print("ADDON_LOADED(\"" .. name .. "\") called.")
  self:UnregisterEvent("ADDON_LOADED")

  -- Post-hook ShadowUF.OnInitialize which is called in response to the
  -- PLAYER_LOGIN event by SUF.
  local originalSUFOnInitialize = _G.ShadowUF.OnInitialize
  _G.ShadowUF.OnInitialize = function(self)
    local values = {originalSUFOnInitialize(self)}
    handlerFrame:PLAYER_LOGIN()
    return _G.unpack(values)
  end

  -- The "vehicle" target also exists for passengers of mounts that allow them
  -- and we don't want to show a frame for them (the player with the mount).
  -- Also, sometimes, the "vehicle" target exists before UnitHasVehicleUI()
  -- returns "true", it seems.
  _G.RegisterStateDriver(vehicleStateHandler, "vehiclestate",
    "[@vehicle,exists,vehicleui]vehicle;novehicle")

  playerFrame:RegisterForClicks("AnyDown")
  vehicleFrame:RegisterForClicks("AnyDown")

  -- Always fires after PLAYER_LOGIN.
  handlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

  handlerFrame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", "player", "vehicle")
  handlerFrame:RegisterUnitEvent("UNIT_MAXHEALTH", "player", "vehicle")
  handlerFrame:RegisterUnitEvent("UNIT_POWER", "player", "vehicle")
  handlerFrame:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player", "vehicle")
  handlerFrame:RegisterUnitEvent("UNIT_MAXPOWER", "player", "vehicle")
  handlerFrame:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player")
  handlerFrame:RegisterUnitEvent("UNIT_HEAL_PREDICTION", "player")
  handlerFrame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "player")
  handlerFrame:RegisterUnitEvent("UNIT_POWER_BAR_SHOW", "player")
  handlerFrame:RegisterUnitEvent("UNIT_POWER_BAR_HIDE", "player")

  -- Fires when the player's spirit is released after death or when the player accepts a
  -- resurrection without releasing.
  handlerFrame:RegisterEvent("PLAYER_ALIVE")

  -- Fires when a player resurrects after being in spirit form.
  handlerFrame:RegisterEvent("PLAYER_UNGHOST")

  pPowerBarAlt:EnableMouse(true)

  self.ADDON_LOADED = nil
end

-- Note: we're not registering for PLAYER_LOGIN ourselves but rather post-hook
-- this function to SUF's PLAYER_LOGIN handler so we can use colors from SUF.
function handlerFrame:PLAYER_LOGIN()
  local healthColor = _G.ShadowUF.db.profile.classColors.DRUID
  local incHealsColor = _G.ShadowUF.db.profile.healthColors.inc
  local manaColor = _G.ShadowUF.db.profile.powerColors.MANA
  local rageColor = _G.ShadowUF.db.profile.powerColors.RAGE
  local energyColor = _G.ShadowUF.db.profile.powerColors.ENERGY
  local vehicleHealthColor = _G.ShadowUF.db.profile.classColors.VEHICLE
  local absorbsColor = _G.ShadowUF.db.profile.healthColors.incAbsorb
  local alternatePowerColor = _G.ShadowUF.db.profile.powerColors.ALTERNATE
  pHealthBar:SetStatusBarColor(healthColor.r, healthColor.g, healthColor.b)
  pHBackground:SetVertexColor(healthColor.r, healthColor.g, healthColor.b, 0.25)
  pIncHealsBar:SetStatusBarColor(incHealsColor.r, incHealsColor.g, incHealsColor.b)
  pAbsorbsBar:SetStatusBarColor(absorbsColor.r, absorbsColor.g, absorbsColor.b)
  gCDBar:SetStatusBarColor(0xd0 / 0xff, 0xd0 / 0xff, 0xd0 / 0xff)
  gCDBackground:SetVertexColor(0xd0 / 0xff, 0xd0 / 0xff, 0xd0 / 0xff, 0.25)
  pEnergyBar:SetStatusBarColor(energyColor.r, energyColor.g, energyColor.b)
  pEBackground:SetVertexColor(energyColor.r, energyColor.g, energyColor.b, 0.25)
  pManaBar:SetStatusBarColor(manaColor.r, manaColor.g, manaColor.b)
  pMBackground:SetVertexColor(manaColor.r, manaColor.g, manaColor.b, 0.25)
  pRageBar:SetStatusBarColor(rageColor.r, rageColor.g, rageColor.b)
  pRBackground:SetVertexColor(rageColor.r, rageColor.g, rageColor.b, 0.25)
  vHealthBar:SetStatusBarColor(vehicleHealthColor.r,
                               vehicleHealthColor.g,
                               vehicleHealthColor.b)
  vHBackground:SetVertexColor(vehicleHealthColor.r,
                              vehicleHealthColor.g,
                              vehicleHealthColor.b, 0.25)
  pPowerBarAlt:SetStatusBarColor(alternatePowerColor.r,
                                 alternatePowerColor.g,
                                 alternatePowerColor.b)
  pPBABackground:SetVertexColor(alternatePowerColor.r,
                                alternatePowerColor.g,
                                alternatePowerColor.b, 0.25)
end

-- We may have missed all sorts of stuff while seeing a loading screen. For
-- example we may have maxed out on energy while seeing the loading screen
-- and won't have received any updates about it. That's why we need to
-- update everything now.
function handlerFrame:PLAYER_ENTERING_WORLD()
  self:UNIT_MAXHEALTH("player")
  self:UNIT_HEALTH_FREQUENT("player")
  self:UNIT_HEAL_PREDICTION("player")
  self:UNIT_ABSORB_AMOUNT_CHANGED("player")
  self:UNIT_MAXPOWER("player")
  self:UNIT_DISPLAYPOWER("player")
  self:UNIT_POWER_FREQUENT("player", "ENERGY")
  self:UNIT_POWER_FREQUENT("player", "MANA")
  self:UNIT_POWER_FREQUENT("player", "RAGE")

  if _G.UnitHasVehicleUI("player") then
    vehicleStateHandler:onVehicleState("vehicle")
  else
    vehicleStateHandler:onVehicleState("novehicle")
    vehicleFrame:Hide()
  end

  if (_G.UnitAlternatePowerInfo("player")) then
    self:UNIT_POWER_BAR_SHOW("player")
    self:UNIT_POWER_FREQUENT("player", "ALTERNATE")
  else
    self:UNIT_POWER_BAR_HIDE("player")
  end
end

handlerFrame:RegisterEvent("ADDON_LOADED")
