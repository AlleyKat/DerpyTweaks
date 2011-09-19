local C,M,L,V = unpack(select(2,...))

local floor = floor
local update = function(self,t)
	self.t_ = self.t_-t
	if self.t_ > 0 then return end
	if self.bar:GetAlpha() == 0 then self:Hide() return end
	if not self.step_one then
		self.a_ = self.timer:GetText()
		self.step_one = true
		return
	end
	if not self.step_two then
		if self.timer:GetText() == self.a_ then return end
		self.step_two = true
		self.a_ = nil
	end
	self.cur = self.cur - t
	if self.cur <0 then self.cur = self.cur + 1 end
	if self.cur >= .1 then
		self.timer_b:SetText("0"..self.timer:GetText()..":"..floor(self.cur*100))
	else
		self.timer_b:SetText("0"..self.timer:GetText()..":0"..floor(self.cur*100))
	end
end

local reset = function(self)
	self.cur = 1
	self.step_two = nil
	self.step_one = nil
	self.t_ = 1
	self.timer_b:SetText("00:00:00")
end

local SkinIt = function(bar)
	local _, originalPoint = bar:GetPoint()

	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", originalPoint, "TOPLEFT", 4, -8)
	bar:SetPoint("BOTTOMRIGHT", originalPoint, "BOTTOMRIGHT", -4, 4)
	
	local timer
	
	for i=1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetAlpha(0)
			timer = region
		end
	end

	bar:SetStatusBarTexture(M["media"].barv)
	bar:SetStatusBarColor(180/255, 14/255, 14/255)

	bar.backdrop = M.frame(bar,nil,nil,true)
	bar.backdrop:SetFrameLevel(0)
	bar.backdrop:SetPoint("TOPLEFT", originalPoint, "TOPLEFT", 0, -4)
	bar.backdrop:SetPoint("BOTTOMRIGHT", originalPoint, "BOTTOMRIGHT")
	
	bar.backdrop.timer_b = M.setcdfont(bar,21)
	bar.backdrop.timer_b:SetText("00:00:00")
	bar.backdrop.timer_b:SetPoint("TOP",bar,"BOTTOM",0,-4)
	bar.backdrop.timer = timer
	bar.backdrop.cur = 1
	bar.backdrop.t_ = 1
	
	bar.backdrop:SetScript("OnUpdate",update)
	bar.backdrop:SetScript("OnShow",reset)
	bar.backdrop:Hide()
	bar.backdrop.bar = bar
	
	local texturebg = bar.backdrop:CreateTexture(nil,"BORDER")
	texturebg:SetPoint("TOPLEFT", 4, -4)
	texturebg:SetPoint("BOTTOMRIGHT", -4 , 4)
	texturebg:SetTexture(M['media'].barv)
	texturebg:SetVertexColor(.1,.1,.1)
	
end


local SkinBlizzTimer = function(self, event)
	for _, b in pairs(TimerTracker.timerList) do
		if not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
		b["bar"].backdrop.cur = 1
		b["bar"].backdrop:Show()
	end
end

local load = CreateFrame("Frame")
load:RegisterEvent("START_TIMER")
load:SetScript("OnEvent", SkinBlizzTimer)