local C,M,L,V = unpack(select(2,...))

local ChangeTemplate = function(self,mods)
	M.setbackdrop(self)
	if mods then
		self:SetBackdrop({
		bgFile = M["media"].blank,
		edgeSize = 0, insets = {left = 2, right = 2, top = 2, bottom = 2}})
		self:SetBackdropColor(unpack(M["media"].color))
		self:SetBackdropBorderColor(0,0,0,0)
		M.style(self,false,2)
	else
		M.style(self)
	end
end

local function SetModifiedBackdrop(self)
	self:SetBackdropColor(.6,.5,.1)
end

local function SetOriginalBackdrop(self)
	self:SetBackdropColor(unpack(M["media"].color))
end

local function SkinButton(f,mods)
	if not f then return end
	f:SetNormalTexture(nil)
	f:SetHighlightTexture(nil)
	f:SetPushedTexture(nil)
	f:SetDisabledTexture(nil)
	ChangeTemplate(f,mods)
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

M.addafter(function(self, event, addon)
	if V.commonskin ~= true then return end
	-- stuff not in Blizzard load-on-demand
		-- Blizzard frame we want to reskin
		local skins = {
			"StaticPopup1",
			"StaticPopup2",
			"GameMenuFrame",
			"InterfaceOptionsFrame",
			"VideoOptionsFrame",
			"AudioOptionsFrame",
			"LFDDungeonReadyStatus",
			"TicketStatusFrameButton",
			"DropDownList1MenuBackdrop",
			"DropDownList2MenuBackdrop",
			"DropDownList1Backdrop",
			"DropDownList2Backdrop",
			"LFDSearchStatus",
			"AutoCompleteBox", -- this is the /w *nickname* box, press tab
			"ReadyCheckFrame",
			"GhostFrameContentsFrame",
		}

		-- reskin popup buttons
		for i = 1, 3 do
			for j = 1, 3 do
				SkinButton(_G["StaticPopup"..i.."Button"..j])
			end
		end
		
		for i = 1, #skins do
			ChangeTemplate(_G[skins[i]])
		end
		
		local ChatMenus = {
			"EmoteMenu",
			"LanguageMenu",
			"VoiceMacroMenu",
		}
 
		for i = 1, #ChatMenus do
			_G[ChatMenus[i]]:HookScript("OnShow", function(self) ChangeTemplate(self) end)
		end
		
		-- reskin all esc/menu buttons
		local BlizzardMenuButtons = {
			"Options", 
			"SoundOptions", 
			"UIOptions", 
			"Keybindings", 
			"Macros",
			"Ratings",
			"AddOns", 
			"Logout", 
			"Quit", 
			"Continue", 
			"MacOptions",
			"Help",
		}
		
		for i = 1, #BlizzardMenuButtons do
			local MenuButtons = _G["GameMenuButton"..BlizzardMenuButtons[i]]
			if MenuButtons then
				SkinButton(MenuButtons,true)
				_G["GameMenuButton"..BlizzardMenuButtons[i].."Left"]:SetAlpha(0)
				_G["GameMenuButton"..BlizzardMenuButtons[i].."Middle"]:SetAlpha(0)
				_G["GameMenuButton"..BlizzardMenuButtons[i].."Right"]:SetAlpha(0)
			end
		end
		
		-- hide header textures and move text/buttons.
		local BlizzardHeader = {
			"GameMenuFrame", 
			"InterfaceOptionsFrame", 
			"AudioOptionsFrame", 
			"VideoOptionsFrame",
			"KeyBindingFrame",
		}
		
		for i = 1, #BlizzardHeader do
			local title = _G[BlizzardHeader[i].."Header"]			
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", BlizzardHeader[i], 0, 0)
				end
			end
		end
		
		-- here we reskin all "normal" buttons
		local BlizzardButtons = {
			"VideoOptionsFrameOkay", 
			"VideoOptionsFrameCancel", 
			"VideoOptionsFrameDefaults", 
			"VideoOptionsFrameApply", 
			"AudioOptionsFrameOkay", 
			"AudioOptionsFrameCancel", 
			"AudioOptionsFrameDefaults", 
			"InterfaceOptionsFrameDefaults", 
			"InterfaceOptionsFrameOkay", 
			"InterfaceOptionsFrameCancel",
			"ReadyCheckFrameYesButton",
			"ReadyCheckFrameNoButton",
		}
		
		for i = 1, #BlizzardButtons do
			SkinButton(_G[BlizzardButtons[i]],true)
		end
		
		-- if a button position or text is not really where we want, we move it here
		_G["VideoOptionsFrameCancel"]:ClearAllPoints()
		_G["VideoOptionsFrameCancel"]:SetPoint("RIGHT",_G["VideoOptionsFrameApply"],"LEFT",-4,0)		 
		_G["VideoOptionsFrameOkay"]:ClearAllPoints()
		_G["VideoOptionsFrameOkay"]:SetPoint("RIGHT",_G["VideoOptionsFrameCancel"],"LEFT",-4,0)	
		_G["AudioOptionsFrameOkay"]:ClearAllPoints()
		_G["AudioOptionsFrameOkay"]:SetPoint("RIGHT",_G["AudioOptionsFrameCancel"],"LEFT",-4,0)
		_G["InterfaceOptionsFrameOkay"]:ClearAllPoints()
		_G["InterfaceOptionsFrameOkay"]:SetPoint("RIGHT",_G["InterfaceOptionsFrameCancel"],"LEFT", -4,0)
		_G["ReadyCheckFrameYesButton"]:SetParent(_G["ReadyCheckFrame"])
		_G["ReadyCheckFrameNoButton"]:SetParent(_G["ReadyCheckFrame"]) 
		_G["ReadyCheckFrameYesButton"]:SetPoint("RIGHT", _G["ReadyCheckFrame"], "CENTER", -1, 0)
		_G["ReadyCheckFrameNoButton"]:SetPoint("LEFT", _G["ReadyCheckFrameYesButton"], "RIGHT", 3, 0)
		_G["ReadyCheckFrameText"]:SetParent(_G["ReadyCheckFrame"])	
		_G["ReadyCheckFrameText"]:ClearAllPoints()
		_G["ReadyCheckFrameText"]:SetPoint("TOP", 0, -12)
		
		-- others
		_G["ReadyCheckListenerFrame"]:SetAlpha(0)
		_G["ReadyCheckFrame"]:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end) -- bug fix, don't show it if initiator
	
		local mm = {
			"GameMenuFrame", 
			"InterfaceOptionsFrame", 
			"AudioOptionsFrame", 
			"VideoOptionsFrame",
			--"KeyBindingFrame",
		}
		
		for i=1,#mm do
			local unmask = _G[mm[i]]:CreateTexture(nil,"border")
			unmask:SetAllPoints(UIParent)
			unmask:SetTexture(0,0,0,.5)
		end
	
	-- mac menu/option panel, made by affli.
	if IsMacClient() then
		-- Skin main frame and reposition the header
		ChangeTemplate(MacOptionsFrame)
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
		--Skin internal frames
		ChangeTemplate(MacOptionsFrameMovieRecording)
		ChangeTemplate(MacOptionsITunesRemote)
 
		--Skin buttons
		SkinButton(_G["MacOptionsFrameCancel"],true)
		SkinButton(_G["MacOptionsFrameOkay"],true)
		SkinButton(_G["MacOptionsButtonKeybindings"],true)
		SkinButton(_G["MacOptionsFrameDefaults"],true)
		SkinButton(_G["MacOptionsButtonCompress"],true)
 
		--Reposition and resize buttons
		local tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsButtonCompress"]:GetPoint()
		_G["MacOptionsButtonCompress"]:SetWidth(136)
		_G["MacOptionsButtonCompress"]:ClearAllPoints()
		_G["MacOptionsButtonCompress"]:SetPoint(tPoint, tRTo, tRP, 4, tY)
 
		_G["MacOptionsFrameCancel"]:SetWidth(96)
		_G["MacOptionsFrameCancel"]:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY =  _G["MacOptionsFrameCancel"]:GetPoint()
		_G["MacOptionsFrameCancel"]:ClearAllPoints()
		_G["MacOptionsFrameCancel"]:SetPoint(tPoint, tRTo, tRP, -14, tY)
 
		_G["MacOptionsFrameOkay"]:ClearAllPoints()
		_G["MacOptionsFrameOkay"]:SetWidth(96)
		_G["MacOptionsFrameOkay"]:SetHeight(22)
		_G["MacOptionsFrameOkay"]:SetPoint("LEFT",_G["MacOptionsFrameCancel"],-99,0)
 
		_G["MacOptionsButtonKeybindings"]:ClearAllPoints()
		_G["MacOptionsButtonKeybindings"]:SetWidth(96)
		_G["MacOptionsButtonKeybindings"]:SetHeight(22)
		_G["MacOptionsButtonKeybindings"]:SetPoint("LEFT",_G["MacOptionsFrameOkay"],-99,0)
 
		_G["MacOptionsFrameDefaults"]:SetWidth(96)
		_G["MacOptionsFrameDefaults"]:SetHeight(22)
		
		-- why these buttons is using game menu template? oO
		_G["MacOptionsButtonCompressLeft"]:SetAlpha(0)
		_G["MacOptionsButtonCompressMiddle"]:SetAlpha(0)
		_G["MacOptionsButtonCompressRight"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsLeft"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsMiddle"]:SetAlpha(0)
		_G["MacOptionsButtonKeybindingsRight"]:SetAlpha(0)
	end
end)

if V.watch_frame == true then
	-- Quest log icons
	local update_icons = function()
		for i=1,25 do
			local a = _G["WatchFrameItem"..i]
			if not a then return end
			if not a.bg_ then
					_G["WatchFrameItem"..i.."IconTexture"]:SetTexCoord(.1,.9,.1,.9)
					a:GetNormalTexture():SetTexture("")
					a:GetPushedTexture():SetTexture(.7,.7,.7,.4)
					a:GetHighlightTexture():SetTexture(.6,.6,.6,.2)
				local bg = M.frame(a,nil,nil,true)
					bg:SetBackdropColor(0,0,0,0)
					bg:SetPoint("TOPLEFT",-4,4)
					bg:SetPoint("BOTTOMRIGHT",4,-4)
					bg:SetFrameLevel(a:GetFrameLevel()+2)
					bg:SetFrameStrata(a:GetFrameStrata())
				a.bg_ = bg
			end
		end
	end
	hooksecurefunc("WatchFrame_Update", update_icons)

	-- fix expand
	M.addenter(function()
		local ex = WatchFrameCollapseExpandButton
		ex:SetAlpha(0)
		
		local mask = M.frame(UIParent,5,"HIGH")
		mask:SetPoint("TOPLEFT",ex,-2,3)
		mask:SetPoint("BOTTOMRIGHT",ex,2,-1)
		M.backcolor(mask,1,.7,.1,.4)
		
		if not ex:IsShown() then mask:Hide() end
		
		local text = mask:CreateFontString(nil,"OVERLAY")
		text:SetFont(M["media"].font_s,16)
		text:SetPoint("CENTER",0,1)
		text:SetText("-")
		text:SetTextColor(1,.7,.1)
		
		mask.on = true
		
		ex:HookScript("OnClick",function() 
			if mask.on == true then
				mask.on = false
					text:SetText("+")
					text:SetPoint("CENTER",0,0)
					text:SetTextColor(1,1,1)
					M.backcolor(mask,0,0,0)
			else
				mask.on = true
					text:SetText("-")
					text:SetPoint("CENTER",0,1)
					text:SetTextColor(1,.7,.1)
					M.backcolor(mask,1,.7,.1,.4)
			end
		end)
		
		ex:HookScript("OnShow",function() mask:Show() end)
		ex:HookScript("OnHide",function() mask:Hide() end)
	end)

	-- WatchFrame
	local f = WatchFrame
	f:SetClampedToScreen(false)
	f:ClearAllPoints()
	f.ClearAllPoints = M.null
	local maskframe___ = CreateFrame("Frame",nil,UIParent)
	maskframe___:SetSize(40,1)
	maskframe___:SetPoint("TOPRIGHT",UIParent,-86,-210)
	f:SetPoint("TOPRIGHT",maskframe___,"BOTTOMRIGHT")
	f:SetPoint("BOTTOMRIGHT",UIParent,-86,150)
	f.SetPoint = M.null
	VehicleSeatIndicator:ClearAllPoints()
	VehicleSeatIndicator:SetPoint("TOPRIGHT",maskframe___,"TOPRIGHT",-24,2)
	VehicleSeatIndicator.SetPoint = M.null
	VehicleSeatIndicator.ClearAllPoints = M.null
	VehicleSeatIndicator:HookScript("OnShow",function(self)
		maskframe___:SetHeight(floor(self:GetWidth()))
	end)
	VehicleSeatIndicator:HookScript("OnHide",function(self) 
		maskframe___:SetHeight(1)
	end)

	-- Durability
	M.kill(DurabilityFrame)

	-- Capture Bar
	local function CaptureUpdate()
		if NUM_EXTENDED_UI_FRAMES then
			local captureBar
			for i=1, NUM_EXTENDED_UI_FRAMES do
				captureBar = getglobal("WorldStateCaptureBar" .. i)
				if captureBar and captureBar:IsVisible() then
					captureBar:ClearAllPoints()
					if( i == 1 ) then
						captureBar:SetPoint("TOP",Minimap,"BOTTOM",0,-9)
					else
						captureBar:SetPoint("TOP", getglobal("WorldStateCaptureBar" .. i - 1 ), "TOP", 0, -25)
					end
				end	
			end	
		end
	end
	hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)
end