local C,M,_,V = unpack(select(2,...))
-- Credit : Haste
if V.loot ~= true then return end
local L = {
	fish = "Fishy loot",
	empty = "Empty slot",
	}

local addon = CreateFrame("Button", "Butsu")
local title = addon:CreateFontString(nil, "OVERLAY")

local iconSize = 22
local frameScale = 1

local sq, ss, sn

local OnEnter = function(self)
	local slot = self:GetID()
	if(LootSlotIsItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end

	self.drop:Show()
	self.drop:SetVertexColor(1, 1, 0)
end

local OnLeave = function(self)
	if(self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	else
		self.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local OnClick = function(self)
	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		ss = self:GetID()
		sq = self.quality
		sn = self.name:GetText()
		LootSlot(ss)
	end
end

local OnUpdate = function(self)
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local createSlot = function(id)
	local iconsize = iconSize-2
	local frame = CreateFrame("Button", 'ButsuSlot'..id, addon)
	frame:SetPoint("LEFT", 8, 0)
	frame:SetPoint("RIGHT", -8, 0)
	frame:SetHeight(iconsize+2)
	frame:SetID(id)

	frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnUpdate", OnUpdate)

	local iconFrame = M.frame(frame,nil,nil,true,true)
	iconFrame:SetHeight(iconsize+8)
	iconFrame:SetWidth(iconsize+8)
	iconFrame:ClearAllPoints()
	iconFrame:SetPoint("RIGHT",frame,4,0)

	local icon = iconFrame:CreateTexture(nil, "ARTWORK")
	icon:SetAlpha(1)
	icon:SetTexCoord(.1, .9, .1, .9)
	icon:SetPoint("TOPLEFT", 4, -4)
	icon:SetPoint("BOTTOMRIGHT", -4, 4)
	icon:SetGradient("VERTICAL",.6,.6,.6,1,1,1)
	frame.icon = icon

	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:ClearAllPoints()
	count:SetJustifyH"RIGHT"
	count:SetPoint("BOTTOMRIGHT", iconFrame, -4.7, 4.3)
	count:SetFont(M["media"].font, 14)
	count:SetShadowOffset(1, -1)
	count:SetShadowColor(0, 0, 0, 1)
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH"LEFT"
	name:ClearAllPoints()
	name:SetPoint("LEFT", frame,.5,1.3)
	name:SetPoint("RIGHT", icon, "LEFT",.5,1.3)
	name:SetNonSpaceWrap(true)
	name:SetFont(M["media"].font, 14, "OUTLINE")
	name:SetShadowOffset(1.5,-1.5)
	name:SetShadowColor(0, 0, 0, 1)
	frame.name = name

	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture(1,1,1,1)
	drop:SetPoint("LEFT", icon, "RIGHT")
	drop:SetPoint("RIGHT", frame)
	drop:SetAllPoints(frame)
	drop:SetAlpha(.555555)
	frame.drop = drop

	addon.slots[id] = frame
	return frame
end

local anchorSlots = function(self)
	local iconsize = iconSize
	local shownSlots = 0
	for i=1, #self.slots do
		local frame = self.slots[i]
		if(frame:IsShown()) then
			shownSlots = shownSlots + 1
			frame:SetPoint("TOP", addon, 4, -8 + iconsize - (shownSlots * (iconsize + 2)))
		end
	end

	self:SetHeight(math.max(shownSlots * iconsize + 16, 20))
end

title:SetFont(M["media"].font,15,"OUTLINE")
title:SetPoint("BOTTOM", addon, "TOP", 0, -2)
title:SetShadowOffset(2,-2)

addon:SetScript("OnMouseDown", function(self) if(IsAltKeyDown()) then self:StartMoving() end end)
addon:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
addon:SetScript("OnHide", function(self)
	StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
	CloseLoot()
end)
addon:SetMovable(true)
addon:RegisterForClicks"anyup"

addon:SetParent(UIParent)
addon:SetUserPlaced(true)
addon:SetPoint("TOPLEFT", 0, -104)
addon:SetWidth(256)
addon:SetHeight(64)

addon:SetClampedToScreen(true)
addon:SetClampRectInsets(0, 0, 14, 0)
addon:SetHitRectInsets(0, 0, -14, 0)
addon:SetFrameStrata"HIGH"
addon:SetToplevel(true)

addon.slots = {}
addon.LOOT_OPENED = function(self, event, autoloot)
	self:Show()

	if(not self:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local items = GetNumLootItems()

	if(IsFishingLoot()) then
		title:SetText(L.fish)
	elseif(not UnitIsFriend("player", "target") and UnitIsDead"target") then
		title:SetText(UnitName"target")
	else
		title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x - 40,y + 20)
		self:GetCenter()
		self:Raise()
	end

	local m, w, t = 0, 0, title:GetStringWidth()
	if(items > 0) then
		for i=1, items do
			local slot = addon.slots[i] or createSlot(i)
			local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality]

			if(LootSlotIsCoin(i)) then
				item = item:gsub("\n", ", ")
			end

			if(quantity > 1) then
				slot.count:SetText(quantity)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			if(quality > 1) then
				slot.drop:SetVertexColor(color.r, color.g, color.b)
				slot.drop:Show()
			else
				slot.drop:Hide()
			end

			slot.quality = quality
			slot.name:SetText(item)
			slot.name:SetTextColor(color.r, color.g, color.b)
			slot.icon:SetTexture(texture)

			m = math.max(m, quality)
			w = math.max(w, slot.name:GetStringWidth())

			slot:Enable()
			slot:Show()
		end
	else
		local slot = addon.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L.empty)
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		items = 1
		w = math.max(w, slot.name:GetStringWidth())

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end
	anchorSlots(self)

	w = w + 60
	t = t + 5

	local color = ITEM_QUALITY_COLORS[m]
	self:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	self:SetWidth(math.max(w, t))
end

addon.LOOT_SLOT_CLEARED = function(self, event, slot)
	if(not self:IsShown()) then return end

	addon.slots[slot]:Hide()
	anchorSlots(self)
end

addon.LOOT_CLOSED = function(self)
	StaticPopup_Hide"LOOT_BIND"
	self:Hide()

	for _, v in pairs(self.slots) do
		v:Hide()
	end
end

addon.OPEN_MASTER_LOOT_LIST = function(self)
	ToggleDropDownMenu(1, nil, GroupLootDropDown, addon.slots[ss], 0, 0)
end

addon.UPDATE_MASTER_LOOT_LIST = function(self)
	UIDropDownMenu_Refresh(GroupLootDropDown)
end

addon.ADDON_LOADED = function(self, event, addon)
	if(addon == "Butsu") then
		db = setmetatable({}, {__index = defaults})

		self:SetScale(frameScale)

		-- clean up.
		self[event] = nil
		self:UnregisterEvent(event)
	end
end

addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

addon:RegisterEvent"LOOT_OPENED"
addon:RegisterEvent"LOOT_SLOT_CLEARED"
addon:RegisterEvent"LOOT_CLOSED"
addon:RegisterEvent"OPEN_MASTER_LOOT_LIST"
addon:RegisterEvent"UPDATE_MASTER_LOOT_LIST"
addon:RegisterEvent"ADDON_LOADED"
addon:Hide()

-- Fuzz
LootFrame:UnregisterAllEvents()
table.insert(UISpecialFrames, "Butsu")

function _G.GroupLootDropDown_GiveLoot(self)
	if ( sq >= MASTER_LOOT_THREHOLD ) then
		local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[sq].hex..sn..FONT_COLOR_CODE_CLOSE, self:GetText())
		if (dialog) then
			dialog.data = self.value
		end
	else
		GiveMasterLoot(ss, self.value)
	end
	CloseDropDownMenus()
end

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(self, data)
	GiveMasterLoot(ss, data)
end