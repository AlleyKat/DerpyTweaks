-- original by haste
local C,M,L,V = unpack(select(2,...))
if V.minor ~= true then return end
local ns = C
ns['lootset'] = {}
local settings = ns['lootset']

local _DEFAULTS = {
	width = 240,
	height = 15,
	texture = M["media"].blank,

	position = {
		["BREATH"] = 'TOP#UIParent#TOP#0#-96';
		["EXHAUSTION"] = 'TOP#UIParent#TOP#0#-119';
		["FEIGNDEATH"] = 'TOP#UIParent#TOP#0#-142';
	};

	colors = {
		EXHAUSTION = {1, .9, 0};
		BREATH = {.222, .444, .888};
		DEATH = {1, .7, 0};
		FEIGNDEATH = {1, .7, 0};
	};
}

do
	settings = setmetatable(settings, {__index = _DEFAULTS})
	for k,v in next, settings do
		if(type(v) == 'table') then
			settings[k] = setmetatable(settings[k], {__index = _DEFAULTS[k]})
		end
	end
end

local Spawn, PauseAll
do
	local barPool = {}

	local loadPosition = function(self)
		local pos = settings.position[self.type]
		local p1, frame, p2, x, y = strsplit("#", pos)

		return self:SetPoint(p1, frame, p2, x,y)
	end

	local OnUpdate = function(self, elapsed)
		if(self.paused) then return end

		self:SetValue(GetMirrorTimerProgress(self.type) / 1e3)
	end

	local Start = function(self, value, maxvalue, scale, paused, text)
		if(paused > 0) then
			self.paused = 1
		elseif(self.paused) then
			self.paused = nil
		end

		self.text:SetText(text)

		self:SetMinMaxValues(0, maxvalue / 1e3)
		self:SetValue(value / 1e3)

		if(not self:IsShown()) then self:Show() end
	end

	function Spawn(type)
		if(barPool[type]) then return barPool[type] end
		local frame = CreateFrame('StatusBar', nil, UIParent)

		frame:SetScript("OnUpdate", OnUpdate)

		local r, g, b = unpack(settings.colors[type])
		
		local bg = M.frame(frame)
		
		bg:SetPoint("TOPLEFT",-4,4)
		bg:SetPoint("BOTTOMRIGHT",4,-4)
		
		local text = frame:CreateFontString(nil, 'OVERLAY')
		text:SetFont(M["media"].font, 14, "LINE")
		text:SetShadowOffset(1,-1)
		text:SetShadowColor(0, 0, 0, 1)

		text:SetJustifyH'CENTER'
		text:SetTextColor(1, 1, 1)

		text:SetPoint('LEFT', frame)
		text:SetPoint('RIGHT', frame)
		text:SetPoint('TOP', frame, 0, 3)
		text:SetPoint('BOTTOM', frame)

		frame:SetSize(settings.width, settings.height)

		frame:SetStatusBarTexture(settings.texture)
		frame:SetStatusBarColor(r, g, b, .8)

		frame.type = type
		frame.text = text

		frame.Start = Start
		frame.Stop = Stop

		loadPosition(frame)

		barPool[type] = frame
		return frame
	end

	function PauseAll(val)
		for _, bar in next, barPool do
			bar.paused = val
		end
	end
end

local frame = CreateFrame'Frame'
frame:SetScript('OnEvent', function(self, event, ...)
	return self[event](self, ...)
end)

function frame:ADDON_LOADED(addon)
		if addon ~= "DerpyTweaks" then return end
		UIParent:UnregisterEvent'MIRROR_TIMER_START'
		self:UnregisterEvent'ADDON_LOADED'
		self.ADDON_LOADED = nil
end
frame:RegisterEvent'ADDON_LOADED'

function frame:PLAYER_ENTERING_WORLD()
	for i=1, MIRRORTIMER_NUMTIMERS do
		local type, value, maxvalue, scale, paused, text = GetMirrorTimerInfo(i)
		if(type ~= 'UNKNOWN') then
			Spawn(type):Start(value, maxvalue, scale, paused, text)
		end
	end
end
frame:RegisterEvent'PLAYER_ENTERING_WORLD'

function frame:MIRROR_TIMER_START(type, value, maxvalue, scale, paused, text)
	return Spawn(type):Start(value, maxvalue, scale, paused, text)
end
frame:RegisterEvent'MIRROR_TIMER_START'

function frame:MIRROR_TIMER_STOP(type)
	return Spawn(type):Hide()
end
frame:RegisterEvent'MIRROR_TIMER_STOP'

function frame:MIRROR_TIMER_PAUSE(duration)
	return PauseAll((duration > 0 and duration) or nil)
end
frame:RegisterEvent'MIRROR_TIMER_PAUSE'
