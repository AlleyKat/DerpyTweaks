local C,M,L,V = unpack(select(2,...))

if V.tooltip ~= true then return end
local _G = getfenv(0)
local GetMouseFocus = GetMouseFocus
local UnitRace = UnitRace
local UnitLevel = UnitLevel
local GetQuestDifficultyColor = GetQuestDifficultyColor
local UnitClassification = UnitClassification
local UnitCreatureType = UnitCreatureType
local UnitIsPlayer = UnitIsPlayer
local GetGuildInfo = GetGuildInfo
local GameTooltipStatusBar = GameTooltipStatusBar
local UnitReaction = UnitReaction
local UnitClass = UnitClass
local UnitIsTapped = UnitIsTapped
local UnitIsTappedByPlayer = UnitIsTappedByPlayer
local oUF = oUF
local UnitExists = UnitExists
local GetCVar = GetCVar
local current_line_hp = 0
local current_unit_hp
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local show_hp = V.tooltip_show_hp

local tooltips =
   {ItemRefTooltip,
   GameTooltip,
   ShoppingTooltip1,
   ShoppingTooltip2,
   ShoppingTooltip3,
   WorldMapTooltip}

local c1,c2,c3,c4 = unpack(M["media"].color)
local s1,s2,s3,s4 = unpack(M["media"].shadow)

-- Hide PVP text
PVP_ENABLED = ""

-- Statusbar
GameTooltipStatusBar:SetStatusBarTexture(M["media"].blank)
GameTooltipStatusBar:ClearAllPoints()
GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, 4, -4)
GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, -4, 4)
GameTooltipStatusBar:SetFrameLevel(1)
GameTooltipStatusBar:SetAlpha(.12345)

if SecondFrameChat then
	local main_anchor = SecondFrameChat.right_holder
	-- Position default anchor
	local function defaultPosition(tt, parent)
		tt:ClearAllPoints()
		tt:SetOwner(parent, "ANCHOR_NONE")
		tt:SetPoint("BOTTOMRIGHT",main_anchor,"TOPRIGHT")
	end
	hooksecurefunc("GameTooltip_SetDefaultAnchor", defaultPosition)
end
local _colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local _reaction = {{.8,.3,.22},{.8,.3,.22},{.75,.27,0},{.9,.7,0},{0,.6,.1},{0,.6,.1},{0,.6,.1},{0,.6,.1}}

if oUF then
	_reaction = oUF.colors.reaction
end

function GameTooltip_UnitColor(unit)
	local c
	if UnitIsPlayer(unit) then
		c = _colors[select(2, UnitClass(unit))]
		c[1],c[2],c[3] = c.r,c.g,c.b
	elseif UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) then
		c = {.5,.5,.5}
	else
		c = _reaction[UnitReaction(unit, "player")]
	end
	if not c then
		c = {.5,.5,.5}
	end
	return c[1], c[2], c[3]
end
local GameTooltip_UnitColor = GameTooltip_UnitColor

local flo = math.floor
local form_health = function(unit)
	local min = UnitHealth(unit)
	local max = UnitHealthMax(unit)
	if max == 0 then
		return "|cffffffffHP:|r 0/0 - 0 %",1,0,0
	end
	local ratio = flo((min/max)*100)
	local r,g
	if ratio >= 70 then
		r = 0; g = 1
	elseif ratio >= 30 then
		r = 1; g  = 1
	else 
		r = 1; g = 0
	end
	return "|cffffffffHP: |r"..min.."/"..max.." - "..ratio.." %",r,g,0
end

-- Unit tooltip style
local OnTooltipSetUnit = function(self)
	-- Most of this code was inspired from 
	-- aTooltip (from alza) based on sTooltip (from Shantalya)

	local lines = self:NumLines()
	local name, unit = self:GetUnit()

	if not unit then return end

	-- Name text, with level and classification
	_G["GameTooltipTextLeft1"]:SetText(name)
	--_G["GameTooltipTextLeft1"]:SetTextColor(GameTooltip_UnitColor(unit))

	local race				= UnitRace(unit)
	local level				= UnitLevel(unit)
	local levelColor		= GetQuestDifficultyColor(level)
	local classification	= UnitClassification(unit)
	local creatureType		= UnitCreatureType(unit)
	
	if level == -1 then
		level = "??"
		levelColor = { r = 1.00, g = 0.00, b = 0.00 }
	end
	
	if classification == "rareelite" then classification = " R+"
	elseif classification == "rare"  then classification = " R"
	elseif classification == "elite" then classification = "+"
	else classification = "" end
	
	if UnitIsPlayer(unit) then
		if GetGuildInfo(unit) then
			_G["GameTooltipTextLeft2"]:SetFormattedText("<%s>", GetGuildInfo(unit))
		end
		
		local n = GetGuildInfo(unit) and 3 or 2
		--  thx TipTac for the fix above with color blind enabled
		if GetCVar("colorblindMode") == "1" then n = n + 1 end
		_G["GameTooltipTextLeft"..n]:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, classification, race)
	else
		for i = 2, lines do
			local line = _G["GameTooltipTextLeft"..i]
			if not line or not line:GetText() then return end
			if (level and line:GetText():find("^"..LEVEL)) or (creatureType and line:GetText():find("^"..creatureType)) then
				line:SetFormattedText("|cff%02x%02x%02x%s%s|r %s", levelColor.r*255, levelColor.g*255, levelColor.b*255, level, classification, creatureType or "")
				break
			end
		end
	end
	
	local _cc = lines+1
	-- ToT line
	if UnitExists(unit.."target") and unit~="player" then
		local r, g, b = GameTooltip_UnitColor(unit.."target")
		GameTooltip:AddLine(UnitName(unit.."target"), r, g, b)
		_cc = _cc+1
	end
	if show_hp then
		GameTooltip:AddLine(form_health(unit))
		current_line_hp = _cc
		current_unit_hp = unit
	end
end

-- Item Ref icon
local itemTooltipIcon = CreateFrame("Frame", "ItemRefTooltipIcon", _G["ItemRefTooltip"])
itemTooltipIcon:SetPoint("TOPRIGHT", _G["ItemRefTooltip"], "TOPLEFT", 2, 0)
itemTooltipIcon:SetHeight(42)
itemTooltipIcon:SetWidth(42)
M.setbackdrop(itemTooltipIcon)
M.style(itemTooltipIcon,true)

itemTooltipIcon.texture = itemTooltipIcon:CreateTexture("ItemRefTooltipIcon", "TOOLTIP")
itemTooltipIcon.texture:SetPoint("TOPLEFT",4,-4)
itemTooltipIcon.texture:SetPoint("BOTTOMRIGHT",-4,4)
itemTooltipIcon.texture:SetTexCoord(.1, .9, .1, .9)
itemTooltipIcon.texture:SetGradient("VERTICAL",.4,.4,.4,1,1,1)

local AddItemIcon = function()
	local frame = _G["ItemRefTooltipIcon"]
	frame:Hide()
	local _, link = _G["ItemRefTooltip"]:GetItem()
	local icon = link and GetItemIcon(link)
	if not icon then return end
	_G["ItemRefTooltipIcon"].texture:SetTexture(icon)
	frame:Show()
end
hooksecurefunc("SetItemRef", AddItemIcon)

local stat_texture = GameTooltipStatusBar:CreateTexture(nil,"OVERLAY")
local y1,y2,y3 = 0,0,0
local r1,r2,r3 = 0,0,0
local sh1,sh2,sh3,sh4 = 0,0,0,0
local refresh_now = false

local pp_recolor = function(self,r,g,b,if_,_status)
	if not(self.top) then return end
	self.top:SetTexture(r,g,b)
	self.bottom:SetTexture(r,g,b)
	self.left:SetTexture(r,g,b)
	self.right:SetTexture(r,g,b)
	r1,r2,r3 = r,g,b
	if if_ then
		self:SetBackdropBorderColor(r,g,b,s4*.4)
	else
		self:SetBackdropBorderColor(s1,s2,s3,s4)
	end
	if _status then
		GameTooltipStatusBar:SetStatusBarColor(r,g,b)
		y1,y2,y3 = r,g,b
	else
		GameTooltipStatusBar:SetStatusBarColor(.1,1,1)
		y1,y2,y3 = .1,1,1
	end
end

GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
	self:SetStatusBarColor(y1,y2,y3)
	if current_unit_hp then
		local hp,r,g,b = form_health(current_unit_hp)
		_G["GameTooltipTextLeft"..current_line_hp]:SetFormattedText("|cff%02x%02x%02x%s|r",r,g,b,hp)
	end
end)

-- Tooltiprecolor. taked from Tukui
local BorderColor = function(self)
	local GMF = GetMouseFocus()
	local unit = (select(2, self:GetUnit())) or (GMF and GMF:GetAttribute("unit"))
	local reaction = unit and UnitReaction("player", unit)
	local player = unit and UnitIsPlayer(unit)
	self:SetBackdropColor(c1,c2,c3,c4)
	if player then
		local class = select(2, UnitClass(unit))
		local c = _colors[class]
		pp_recolor(self,c.r,c.g,c.b,true,true)
	elseif reaction then
		local c = _reaction[reaction]
		pp_recolor(self,c[1],c[2],c[3],true,true)
	else
		local _, link = self:GetItem()
		local quality = link and select(3, GetItemInfo(link))
		if quality and quality >= 2 then
			local r, g, b = GetItemQualityColor(quality)
			pp_recolor(self,r,g,b,true,false)
		else
			pp_recolor(self,0,0,0,false,false)
		end
	end
	refresh_now = true
	self:SetSize(floor(self:GetWidth()),floor(self:GetHeight()))
end

GameTooltip:HookScript("OnUpdate",function(self,t)
	if refresh_now then
		if self:GetAnchorType() == "ANCHOR_CURSOR" then 
			refresh_now = false
			pp_recolor(self,0,0,0,false,false)
			self:SetBackdropColor(c1,c2,c3,c4)
		end
	end
end)

M.addafter(function()
	for _, tt in pairs(tooltips) do
		M.setbackdrop(tt)
		M.style(tt)
		tt:HookScript("OnShow",BorderColor)
	end
	if V.tooltip_hide_in_combat then
		GameTooltip:HookScript("OnShow",function(self) 
			if InCombatLockdown() then
				self:Hide()
			end
		end)
		GameTooltip:RegisterEvent("PLAYER_REGEN_DISABLED")
		GameTooltip:SetScript("OnEvent",function(self) self:Hide() end)
	end
end)
GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)