local C,M,L,V = unpack(select(2,...))

if V.combat then
	local a = CreateFrame ("Frame")
		a:RegisterEvent("PLAYER_REGEN_ENABLED")
		a:RegisterEvent("PLAYER_REGEN_DISABLED")
		a:SetScript("OnEvent", function (self,event)
			if (UnitIsDead("player")) then return end
			if event == "PLAYER_REGEN_ENABLED" then
				M.allertrun("LEAVING COMBAT",0.1,1,0.1)
			else
				M.allertrun("ENTERING COMBAT",1,0.1,0.1)
			end	
		end)
end

if V.shadow then
	local change_u, change_d
	local shadow = CreateFrame ("Frame")
		shadow:SetFrameLevel(0)
		shadow:SetFrameStrata("BACKGROUND")
		shadow.tex = shadow:CreateTexture(nil,"BORDER")
		shadow.tex:SetTexture([=[Interface\AddOns\HissyMedia\media\shadow]=])
		shadow.tex:SetVertexColor(0,0,0,1)
		shadow.tex:SetAllPoints(UIParent)	
	local ssh_event = function(self,event)
		if UnitIsDead("player") or UnitIsGhost("player") then
			if change_u then return end
			change_u = true
			change_d = false
			UIFrameFadeIn(shadow,4.5,.4,1)
			M.sl_run(GetUnitName("player")..": Dead",1,.1,.1)
		else
			if change_d then return end
			change_d = true
			change_u = false
			UIFrameFadeOut(shadow,4.5,1,.4)
			M.sl_run(GetUnitName("player")..": Alive",.1,1,.1)
		end
	end
	shadow:RegisterEvent("PLAYER_UNGHOST")
	shadow:RegisterEvent("PLAYER_DEAD")
	shadow:RegisterEvent("PLAYER_ENTERING_WORLD")
	shadow:RegisterEvent("PLAYER_ALIVE")
	shadow:SetScript("OnEvent",ssh_event)
end

M.addafter(function()
	local k = CreateFrame("Frame")
	k.p_id = UnitGUID("player")
	k:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	k:SetScript("OnEvent", function(self, _, _, partykill,_, guid, ...)
			if partykill == "PARTY_KILL" and guid == self.p_id then
				local _,_,_,_,a = ...;
				M.sl_run("Killing Blow: "..a.."!",1,1,.1)
			end
	end)
end)