-- local C,M,L,V = unpack(select(2,...)) --

local ns = select(2,...)
ns[1] = {}
ns[2] = DerpyData[1]
ns[3] = DerpyData[2]

if not _G.DerpyTweaksVar then
	_G.DerpyTweaksVar = {
		["watch_frame"] = true,
		["commonskin"] = true,
		["combat"] = true,
		["shadow"] = true,
		["error"] = true,
		["loot"] = true,
		["lootroll"] = true,
		["tooltip_show_hp"] = true,
		["tooltip_hide_in_combat"] = true,
		["tooltip"] = true,
	}
end

ns[4] = _G.DerpyTweaksVar
local M = ns[2]
local V = ns[4] 
local mis
M.call.mis = function()
	if mis then mis:Show() return end
	local st = {
		["tooltip"] = "Tooltip",
		["tooltip_show_hp"] = "Show Tooltip HP",
		["tooltip_hide_in_combat"] = "Hide Tooltip In Combat",
		["minimap"] = "Minimap",
		["map"] = "Map",
		["loot"] = "Loot",
		["lootroll"] = "Loot Roll",
		["minor"] = "Minor Bars",
		["weaponench"] = "Enchants",
		["shadow"] = "Shadow",
		["combat"] = "Combat Msg",
		["top"] = "Top Panel",
		["map"] = "Map",
		["zone_change"] = "Zone Name Update",
		["map_bg"] = "Battlefield Map",
		["bottom"] = "Bottom Panel",
		["lockscale"] = "Lock UIScale", -- !
		["replacefont"] = "Replace Font",
		["watch_frame"] = "Watch Frame",
		["topleft_mes"] = "Top Left Warnings",
		["skin"] = "Skin",}
		mis = M.make_settings(st,V,72,250,"MISCELLANEOUS",true)
	--	local y = M.makevarbar(mis,250,0,200,V,'map_size_ratio',"Map Size Ratio"); y:SetPoint("TOP",mis,0,-27)
	--	M.makevarbar(mis,250,0,16,V,"font_offset","Font Size Ratio"):SetPoint("TOP",y,"BOTTOM")
	mis:Show()
end