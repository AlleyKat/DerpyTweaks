local C,M,L,V = unpack(select(2,...))

M.addenter(function()
	M.kill(CharacterFrameCloseButton)
	
	local _G = _G
	local slots = {
	"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
	"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
	"SecondaryHand", "Ranged", "Tabard",}
	local mod_tex = function(self,mode)
		if mode then
			self:GetHighlightTexture():SetTexture(1,1,1,.1)
		else
			tx = self:CreateTexture(nil,"HIGHLIGHT")
			tx:SetAllPoints()
			tx:SetTexture(1,1,1,.1)
		end
		self:GetPushedTexture():SetTexture(0,0,0,.4)
	end
	local set_vertex = function(self,r,g,b)
		if r == self._r and g == self.g and b == self._b then return end
		self._r = r
		self._g = g
		self._b = b
		self:SetGradient("VERTICAL",r*.5,g*.5,b*.5,r,g,b)
	end
	local GetInventoryItemID = GetInventoryItemID
	local GetItemQualityColor = GetItemQualityColor
	local seticon = function(self,icon)
		if icon == self._icon then return end
		self._icon = icon
		self:_SetTexture(icon)
		local itemLink = GetInventoryItemID('player',self.slotID)
		if itemLink then
			local _, _, itemQuality = GetItemInfo(itemLink)
			if itemQuality and itemQuality > 1 then
				local r, g, b = GetItemQualityColor(itemQuality)
				self.bg:backcolor(r,g,b,.88)
			else
				self.bg:backcolor(0,0,0)
			end
		else
			self.bg:backcolor(0,0,0)
		end
	end
	for i=1,#slots do
		local icon = _G["Character"..slots[i].."SlotIconTexture"]
		local slot = _G["Character"..slots[i].."Slot"]
		M.untex(slot)
		mod_tex(slot)
		slot:SetFrameLevel(4)
		slot:SetSize(41,33)
		local bg = M.frame(slot,3,"MEDIUM",true)
		icon.SetVertexColor = set_vertex
		icon:SetTexCoord(4/45,1-4/45,8/45,1-8/45)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT")
		icon:SetPoint("BOTTOMRIGHT")
		icon._SetTexture = icon.SetTexture
		icon.SetTexture = seticon
		icon.slotID = i % 20
		icon.bg = bg
		bg:points(icon)
	end
	_G.CharacterHeadSlot:ClearAllPoints()
	_G.CharacterHeadSlot:SetPoint("TOPLEFT",0,-66)
	_G.CharacterHandsSlot:ClearAllPoints()
	_G.CharacterHandsSlot:SetPoint("TOPLEFT",294,-66)
	slots = {"CharacterHeadSlot",
			"CharacterNeckSlot",
			"CharacterShoulderSlot",
			"CharacterBackSlot",
			"CharacterChestSlot",
			"CharacterShirtSlot",
			"CharacterTabardSlot",
			"CharacterWristSlot",}
	for i=2,#slots do
		_G[slots[i]]:ClearAllPoints()	
		_G[slots[i]]:SetPoint("TOP",_G[slots[i-1]],"BOTTOM",0,-8)
	end
	slots = {"CharacterHandsSlot",
			"CharacterWaistSlot",
			"CharacterLegsSlot",
			"CharacterFeetSlot",
			"CharacterFinger0Slot",
			"CharacterFinger1Slot",
			"CharacterTrinket0Slot",
			"CharacterTrinket1Slot",}
	for i=2,#slots do
		_G[slots[i]]:ClearAllPoints()	
		_G[slots[i]]:SetPoint("TOP",_G[slots[i-1]],"BOTTOM",0,-8)
	end
	slots = {"CharacterMainHandSlot",
			"CharacterSecondaryHandSlot",
			"CharacterRangedSlot",}
	for i=1,#slots do
		local slot = _G[slots[i]]
		slot:SetSize(47,37)
		slot:ClearAllPoints()
		if slots[i] ~= "CharacterMainHandSlot" then
			slot:SetPoint("LEFT",_G[slots[i-1]],"RIGHT",11,0)
		else
			slot:SetPoint("BOTTOMLEFT",86,14)
		end
	end
	local charframe = {
		"CharacterFrame",
		"CharacterModelFrame",
		"CharacterFrameInset", 
		"CharacterStatsPane",
		"CharacterFrameInsetRight",
		"PaperDollSidebarTabs",
		"PaperDollEquipmentManagerPane",
		"PaperDollFrameItemFlyout",
		"PaperDollFrame",
	}
	local function SkinItemFlyouts()
		M.untex(PaperDollFrameItemFlyoutButtons)
		for i=1, PDFITEMFLYOUT_MAXITEMS do
			local button = _G["PaperDollFrameItemFlyoutButtons"..i]
			local icon = _G["PaperDollFrameItemFlyoutButtons"..i.."IconTexture"]
			if button then
				mod_tex(button,true)				
				button:GetNormalTexture():SetTexture(nil)
				icon:ClearAllPoints()
				icon:SetAllPoints()	
				button:SetSize(29,33)
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				if not button.backdrop then
					local bg = M.frame(button,button:GetFrameLevel()-1,"MEDIUM") 
					bg:points()
					button.backdrop = bg
					icon:SetTexCoord(5/32,1-5/32,3/32,1-3/32)
					icon.SetVertexColor = set_vertex
					icon:SetVertexColor(1,1,1)
				end
				if i==1 then
					button.backdrop:backcolor(1,1,.2,.4)
				else
					button:ClearAllPoints()
					button:SetPoint("LEFT",	_G["PaperDollFrameItemFlyoutButtons"..i-1],"RIGHT",9,0)		
				end
			end
		end	
	end
	
	M.kill(_G.CharacterModelFrameRotateLeftButton)
	M.kill(_G.CharacterModelFrameRotateRightButton)
	
	--Swap item flyout frame (shown when holding alt over a slot)
	PaperDollFrameItemFlyout:HookScript("OnShow", SkinItemFlyouts)
	hooksecurefunc("PaperDollItemSlotButton_UpdateFlyout", SkinItemFlyouts)

	local scrollbars = {
		"PaperDollTitlesPaneScrollBar",
		"PaperDollEquipmentManagerPaneScrollBar",
		"CharacterStatsPaneScrollBar",
		"GearManagerDialogPopupScrollFrameScrollBar",
		"ReputationListScrollFrameScrollBar",
	}
	
	for _, scrollbar in pairs(scrollbars) do
		M.unscroll(_G[scrollbar])
	end
	
	for _, object in pairs(charframe) do
		M.untex(_G[object])
	end
	
	CharacterStatsPaneScrollBar:SetAllPoints(PaperDollTitlesPaneScrollBar)
	CharacterStatsPaneScrollBarScrollUpButton:SetAllPoints(PaperDollTitlesPaneScrollBarScrollUpButton)
	CharacterStatsPaneScrollBarScrollDownButton:SetAllPoints(PaperDollTitlesPaneScrollBarScrollDownButton)
	
	local back = M.frame(CharacterFrame,1,CharacterFrame:GetFrameStrata())
	back:SetPoint("TOPLEFT",-14,-43)
	back:SetPoint("BOTTOMRIGHT",11,-8)
	PaperDollFrame:EnableMouse(false)
	back.bg:SetDrawLayer("OVERLAY")
	
	local gen_surc = function(parent)
		local t = parent:CreateTexture(nil,"BORDER")
		t:SetSize(353,353)
		t:SetTexture(M.media.prizvstudiu)
		t:SetVertexColor(RAID_CLASS_COLORS[M.class].r,RAID_CLASS_COLORS[M.class].g,RAID_CLASS_COLORS[M.class].b,1)
		local x = 0
		local rotate = t:CreateAnimationGroup("lol")
		local a = rotate:CreateAnimation("Rotation")
		a:SetDuration(120) 
		a:SetOrder(1) 
		a:SetDegrees(3600)
		rotate:SetLooping("REPEAT")
		t.r = rotate
		t.play = function(self) self.r:Play() end
		t.stop = function(self) self.r:Stop() end
		return t
	end
	
	local t = gen_surc(back)
	t:SetPoint("CENTER",CharacterModelFrame)
	t:Hide() 
	
	local bl1 = back:CreateTexture(nil,"ARTWORK")
	bl1:SetWidth(62)
	bl1:SetTexture(0,0,0,1)
	bl1:SetPoint("TOPLEFT",4,-4)
	bl1:SetPoint("BOTTOMLEFT",4,4)
	
	local bl2 = back:CreateTexture(nil,"ARTWORK")
	bl2:SetTexture(0,0,0,1)
	bl2:SetPoint("TOPLEFT",297,-4)
	bl2:SetPoint("BOTTOMLEFT",297,4)
	bl2:SetPoint("TOPRIGHT",-4,-4)
	bl2:SetPoint("BOTTOMRIGHT",-4,4)
	
	local bl3 = back:CreateTexture(nil,"ARTWORK")
	bl3:SetHeight(70)
	bl3:SetTexture(0,0,0,1)
	bl3:SetPoint("BOTTOMLEFT",4,4)
	bl3:SetPoint("BOTTOMRIGHT",-4,4)
	
	local bl4 = back:CreateTexture(nil,"ARTWORK")
	bl4:SetHeight(40)
	bl4:SetTexture(0,0,0,1)
	bl4:SetPoint("TOPLEFT",4,-4)
	bl4:SetPoint("TOPRIGHT",-4,-4)
	
	local bgchar = M.frame(CharacterModelFrame,2,CharacterFrame:GetFrameStrata(),true)
	bgchar:points()
	bgchar:SetBackdrop(M.bg_edge)
	bgchar:SetBackdropBorderColor(unpack(M.media.shadow))
	
	local topbgchar =  M.frame(CharacterModelFrame,2,CharacterFrame:GetFrameStrata())
	topbgchar:SetBackdropBorderColor(0,0,0,0)
	topbgchar:SetPoint("TOPLEFT",bgchar)
	topbgchar:SetPoint("TOPRIGHT",bgchar)
	topbgchar:SetHeight(35)
	
	local bottombgchar =  M.frame(CharacterModelFrame,2,CharacterFrame:GetFrameStrata())
	bottombgchar:SetBackdropBorderColor(0,0,0,0)
	bottombgchar:SetPoint("BOTTOMLEFT",bgchar)
	bottombgchar:SetPoint("BOTTOMRIGHT",bgchar)
	bottombgchar:SetHeight(35)
	
	local left = back:CreateTexture(nil,"OVERLAY")
	left:SetPoint("TOPLEFT",bgchar,4,-4)
	left:SetPoint("BOTTOMLEFT",bgchar,4,4)
	left:SetPoint("RIGHT",bgchar,"CENTER")
	left:SetTexture(M.media.blank)
	left:SetGradientAlpha("HORIZONTAL",0,0,0,.8,0,0,0,0)
	left:Hide()
	
	local right = back:CreateTexture(nil,"OVERLAY")
	right:SetPoint("TOPRIGHT",bgchar,-4,-4)
	right:SetPoint("BOTTOMRIGHT",bgchar,-4,4)
	right:SetPoint("LEFT",bgchar,"CENTER")
	right:SetTexture(M.media.blank)
	right:SetGradientAlpha("HORIZONTAL",0,0,0,0,0,0,0,.8)
	right:Hide()
	
	local myname = M.setfont(topbgchar,19,nil,"ARTWORK")
	myname:SetText(GetUnitName("player"))
	myname:SetPoint("LEFT",9,.4)
	myname:SetTextColor(RAID_CLASS_COLORS[M.class].r,RAID_CLASS_COLORS[M.class].g,RAID_CLASS_COLORS[M.class].b,1)
	
	local lvl = M.setfont(topbgchar,19,nil,"ARTWORK","RIGHT")
	lvl:SetPoint("RIGHT",-9,.4)
	lvl:SetTextColor(1,1,.1,1)
	
	CharacterModelFrame.___t = t
	CharacterModelFrame._right = right
	CharacterModelFrame._left = left
	CharacterModelFrame._lvl = lvl

	local PaperDollTitlesPane = PaperDollTitlesPane
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.Check:SetTexture(nil)
			object:GetHighlightTexture():SetTexture(.2,.7,1,.4)
			local x = select(6,object:GetRegions())
			x:SetTexture(1,1,.2,.5)
		end
	end)
	
	local sl = {
		"PaperDollEquipmentManagerPane",
		"PaperDollTitlesPane",
		"CharacterStatsPane",}
	for i=1,#sl do
		local x = _G[sl[i]]
		x:ClearAllPoints()
		if sl[i] ~= "CharacterStatsPane" then
			x:SetPoint("TOPRIGHT",back,-34,-24)
			x:SetPoint("BOTTOMRIGHT",back,-34,14)
		else
			x:SetPoint("TOPRIGHT",back,-34,-23)
			x:SetPoint("BOTTOMRIGHT",back,-34,15)
		end
		x:SetWidth(173)
	end
	
	local expand_button_template = M.frame(CharacterModelFrame,2,"MEDIUM",true)
	expand_button_template:SetSize(49,29)
	local x = expand_button_template:CreateTexture(nil,"BORDER")
	x:SetSize(64,64)
	x:SetTexture(M.media.path.."arrow_one.tga")
	x:SetPoint("TOPLEFT",4,-4)
	x:SetGradient("VERTICAL",0,0,0,.9,.9,.9)
	expand_button_template:SetPoint("TOP",_G.CharacterTrinket1Slot,"BOTTOM",0,-7)
	M.untex(CharacterFrameExpandButton)
	CharacterFrameExpandButton:SetAllPoints(expand_button_template)
	CharacterFrameExpandButton:SetFrameLevel(0)
	CharacterFrameExpandButton:SetAlpha(0)
	CharacterFrameExpandButton.SetAlpha = M.null
	CharacterFrameExpandButton:HookScript("OnEnter",function(self) self.bg:backcolor(1,1,.2,.8) end)
	CharacterFrameExpandButton:HookScript("OnLeave",function(self) self.bg:backcolor(0,0,0) end)
	CharacterFrameExpandButton.bg = expand_button_template
	
	CharacterModelFrame:HookScript("OnHide", function(self) 
		self.___t:stop()
		self.___t:Hide()
		self._left:Hide()		
		self._right:Hide()	
	end)
	CharacterModelFrame:HookScript("OnShow", function(self)
		self.___t:play()
		self.___t:Show() 
		self._left:Show()		
		self._right:Show()
		self._lvl:SetText(UnitLevel("player"))
	end)
	
	--Equipement Manager
	local _t = function(self) self.bg:backcolor(1,1,1,.8) end
	local __t = function(self) self.bg:backcolor(0,0,0) end
	local _temp_gen = function(self)
		M.untex(self,true)
		if self.bg then return end
		local x = M.frame(self,self:GetFrameLevel()-1,"MEDIUM")
		x:SetPoint("CENTER",self)
		self.bg = x
		self:HookScript("OnEnter",_t)
		self:HookScript("OnLeave",__t)
		return x
	end
	_temp_gen(PaperDollEquipmentManagerPaneEquipSet):SetSize(87,30)
	_temp_gen(PaperDollEquipmentManagerPaneSaveSet):SetSize(87,30)
	PaperDollEquipmentManagerPaneEquipSet:SetPoint("TOPLEFT", PaperDollEquipmentManagerPane, "TOPLEFT", 2, 1)
	PaperDollEquipmentManagerPaneEquipSet:SetFrameLevel(10)
	PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", -1, 0)
	PaperDollEquipmentManagerPaneSaveSet:SetFrameLevel(10)
	PaperDollEquipmentManagerPaneEquipSet.ButtonBackground:SetTexture(nil)
	PaperDollEquipmentManagerPane:HookScript("OnShow", function(self)
		for x, object in pairs(PaperDollEquipmentManagerPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.Check:SetTexture(nil)
			object.HighlightBar:SetTexture(.2,.7,1,.4)
			object.SelectedBar:SetTexture(1,1,.2,.5)
			if not object.backdrop then
				local x = M.frame(object,2,"MEDIUM",true)
				x:points(object.icon)
				object.backdrop = x
				object.icon:SetTexCoord(5/32,1-5/32,3/32,1-3/32)
				object.icon.SetVertexColor = set_vertex
				object.icon:SetVertexColor(1,1,1)
				object.icon.SetPoint = M.null
				object.icon.SetSize = M.null
			end
			object.icon:SetParent(object.backdrop)
			object.icon:SetPoint("LEFT", object, "LEFT", 4, 0)
			object.icon:SetSize(32,36)
		end
		if not GearManagerDialogPopup.bg then
			M.untex(GearManagerDialogPopup,true)
			local x = M.frame(GearManagerDialogPopup,GearManagerDialogPopup:GetFrameLevel()-1,"MEDIUM")
			x:points()
			GearManagerDialogPopup.bg = x
			M.un_custom_regions(GearManagerDialogPopupEditBox,6,8)
			_temp_gen(GearManagerDialogPopupOkay):SetSize(76,24)
			_temp_gen(GearManagerDialogPopupCancel):SetSize(76,24)
			M.untex(_G.GearManagerDialogPopupScrollFrame)
		end
		GearManagerDialogPopup:SetPoint("TOPLEFT", PaperDollFrame, "TOPRIGHT", -2, -64)		
		for i=1, NUM_GEARSET_ICONS_SHOWN do
			local button = _G["GearManagerDialogPopupButton"..i]
			local icon = button.icon
			if button then	
				_G["GearManagerDialogPopupButton"..i.."Icon"]:SetTexture(nil)
				icon:ClearAllPoints()
				icon:SetAllPoints()	
				button:SetFrameLevel(button:GetFrameLevel() + 2)
				if not button.backdrop then
					local select = select	
					M.un_custom_regions(button,2,2)
					local x = select(5,button:GetRegions())
					x:SetTexture(1,1,.2,.3)
					local x = select(4,button:GetRegions())
					x:SetTexture(1,1,1,.1)
					icon:SetTexCoord(.1,.9,.1,.9)
					icon.SetVertexColor = set_vertex
					icon:SetVertexColor(1,1,1)
					local bg = M.frame(button,button:GetFrameLevel()-1,"MEDIUM",true)
					bg:points()
					button.backdrop = bg
				end
			end
		end
	end)
	
	--Handle Tabs at bottom of character frame
	local skintab = function(self)
		M.untex(self,true)
		local bg = M.frame(self,0,"MEDIUM")
		bg:SetPoint("TOPLEFT",8,20)
		bg:SetPoint("BOTTOMRIGHT",-8,5.2)
		local text = select(7,self:GetRegions())
		text:SetFont(M.media.font,13)
		text:SetShadowOffset(1,-1)
		text.SetFont = M.null
		text:ClearAllPoints()
		text:SetPoint("BOTTOM",bg,0,7)
		text.SetPoint = M.null
	end
	for i=1, 4 do
		skintab(_G["CharacterFrameTab"..i])
	end
	
	--Buttons used to toggle between equipment manager, titles, and character stats
	local function FixSidebarTabCoords()
		for i=1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]
			if tab then
				tab.Highlight:SetTexture(nil)
				tab.Hider:SetTexture(nil)
				tab.Show = M.null
				M.kill(tab.TabBg)
				if i == 1 then
					for i=1, tab:GetNumRegions() do
						local region = select(i, tab:GetRegions())
						region:Hide()
						region.Show = M.null
					end
					tab:ClearAllPoints()
					tab:UnregisterAllEvents()
					tab:SetPoint("BOTTOMRIGHT",tab:GetParent(),"TOPRIGHT",-118,-30)
					local tex = tab:CreateTexture(nil,"ARTWORK")
					tex:SetPoint("CENTER",tab,-3,-2)
					tex:SetSize(32,32)
					tex:SetTexture(M.media.path.."stats.tga")
				else
					tab:ClearAllPoints()
					tab:SetPoint("LEFT",_G["PaperDollSidebarTab"..i-1],"RIGHT",i==2 and 10 or 8,i~=2 and -1 or 1)				
				end	
			end
		end
	end
	hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", FixSidebarTabCoords)
	--PaperDollSidebarTab1
	
	--Stat panels, atm it looks like 7 is the max
	for i=1, 7 do
		M.untex(_G["CharacterStatsPaneCategory"..i],true)
	end
	
	local what_color = function(self,texture)
		if texture == "Interface\\Buttons\\UI-MinusButton-Up" then
			self._mod:SetTexture(0,.7,1,.666)
		else
			self._mod:SetTexture(1,.7,0,.666)
		end
	end
	
	--Reputation
	local function UpdateFactionSkins()
		local ReputationListScrollFrame = ReputationListScrollFrame
		local ReputationFrame = ReputationFrame
		M.untex(ReputationListScrollFrame)
		M.untex(ReputationFrame)
		ReputationListScrollFrame:ClearAllPoints()
		ReputationListScrollFrame:SetPoint("TOP",0,-60)
		ReputationListScrollFrame:SetPoint("BOTTOM",0,8)
		ReputationListScrollFrame:SetPoint("RIGHT",-24,0)
		ReputationListScrollFrame:SetPoint("LEFT",0,0)
		ReputationFrame:ClearAllPoints()
		ReputationFrame:SetPoint("TOP",0,0)
		ReputationFrame:SetPoint("BOTTOM",0,0)
		ReputationFrame:SetPoint("RIGHT",0,0)
		ReputationFrame:SetPoint("LEFT",-8,0)
		for i=1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]
			
			if statusbar then
				
				if not statusbar.backdrop then
					statusbar.backdrop = M.frame(statusbar,statusbar:GetFrameLevel()-1,"MEDIUM")
					statusbar.backdrop:points()
					statusbar:SetSize(floor(statusbar:GetWidth()+.5+10),14)
					statusbar:SetStatusBarTexture(M["media"].barv)
					M.kill(_G["ReputationBar"..i.."LeftLine"])
					M.kill(_G["ReputationBar"..i.."BottomLine"])
					_G["ReputationBar"..i.."Background"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)	
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
				end
			
			end
			local colapse = _G["ReputationBar"..i.."ExpandOrCollapseButton"]
			if colapse then
				if not colapse._mod then
					local a = colapse:GetNormalTexture()
					colapse.SetNormalTexture = what_color
					colapse._mod = a
					colapse:SetNormalTexture(a:GetTexture())
					a:SetSize(18,10)
					a:ClearAllPoints()
					a:SetPoint("CENTER",2,1)
					a = colapse:GetHighlightTexture()
					a:SetTexture(1,.7,1,.666)
					a.SetTexture = M.null
					a:SetSize(18,10)
					a:ClearAllPoints()
					a:SetPoint("CENTER",2,1)
				end			
			end
		end
		if not ReputationDetailFrame.bg then
			local bg = M.frame(ReputationDetailFrame,1,"MEDIUM")
			bg:SetPoint("TOPRIGHT",4,4)
			bg:SetPoint("BOTTOMLEFT",-10,-4)
			ReputationDetailFrame.bg = bg
			M.untex(ReputationDetailFrame,true)
		end
		ReputationDetailFrame:ClearAllPoints()
		ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -58)			
	end	
	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	hooksecurefunc("ExpandFactionHeader", UpdateFactionSkins)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionSkins)
	
	--Currency
	TokenFrame:HookScript("OnShow", function()
		local TokenFrameContainer = TokenFrameContainer
		TokenFrameContainer:ClearAllPoints()
		TokenFrameContainer:SetPoint("TOPLEFT",8,-60)
		TokenFrameContainer:SetPoint("BOTTOMRIGHT",-10,8)
		for i=1, GetCurrencyListSize() do
			local button = _G["TokenFrameContainerButton"..i]
			if button then
				M.kill(button.highlight)
				M.kill(button.categoryMiddle)
				M.kill(button.categoryLeft)
				M.kill(button.categoryRight)
				if button.icon then
					button.icon:SetTexCoord(.1, .9, .1, .9)
				end
			end
		end
		if not TokenFramePopup.bg then
			local bg = M.frame(TokenFramePopup,1,"MEDIUM")
			bg:SetPoint("TOPRIGHT",4,4)
			bg:SetPoint("BOTTOMLEFT",-10,-4)
			TokenFramePopup.bg = bg
			M.untex(TokenFramePopup,true)
		end
		TokenFramePopup:ClearAllPoints()
		TokenFramePopup:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -58)			
	end)
	
	--Pet
	PetPaperDollFrame:EnableMouse(false)
	M.untex(PetPaperDollFrame)
	local back = M.frame(PetModelFrame,2,"MEDIUM")
	back:SetBackdrop({bgFile = M.media.path.."wallbig.tga", tile = true, 
	tileSize = 340,
	edgeFile = M["media"].glow,edgeSize = 4,
	insets = {left = 3, right = 3, top = 3, bottom = 3}})
	back:backcolor(0,0,0)
	back:points()
	PetModelFrame.bg = back
	PetModelFrame:HookScript("OnShow",function(self)
		if UnitIsPVPFreeForAll("pet") then
			self.bg:SetBackdropColor(.93,.93,.07)
		elseif UnitIsPVP("pet") then
			self.bg:SetBackdropColor(.07,.93,.07)
		else
			self.bg:SetBackdropColor(.07,.07,.93)
		end
	end)
	M.kill(PetModelFrameRotateRightButton)
	M.kill(PetModelFrameRotateLeftButton)
	M.kill(PetPaperDollFrameExpBar)
	PetPaperDollPetInfo:SetSize(24, 24)
	local not_compl = M.setfont(PetModelFrame,14)
	not_compl:SetText("THIS FRAME IS NOT COMPLITED YET")
	not_compl:SetPoint("BOTTOMLEFT",8,6)
end)
