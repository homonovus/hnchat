if not hnchat then return end

if SERVER then return end

concommand.Add( "hnchat_open_config", function() -- opens config panel
	hnchat.openChatbox("Settings")
end)

configstuff = vgui.Create("DPanel")
local function AddSettingsOption( parent, txt, cvar, valon, valoff )
	local opt = vgui.Create("DMenuOptionCVar")

	opt.OnCursorEntered = function() return end

	opt:SetConVar(cvar)
	opt:SetText(tostring(txt))
	opt:SetToolTip("CVar: " .. cvar)
	opt:SetValueOn(tostring(valon))
	opt:SetValueOff(tostring(valoff))
	opt:SizeToContents()

	parent:AddItem(opt)

	return opt
end
local function AddSettingsSpacer( parent )
	local pnl = vgui.Create( "DPanel", parent )
	pnl.Paint = function( p, w, h )
		derma.SkinHook( "Paint", "MenuSpacer", p, w, h )
	end

	pnl:SetTall(1)
	parent:AddItem(pnl)

	return pnl
end
local function AddSettingsSlider( parent, txt, cvar, decplace, min, max )
	local sld = vgui.Create("DNumSlider")

	sld:SetConVar(cvar)
	sld:SetText(tostring(txt))
	sld:SetMin(tonumber(min))
	sld:SetMax(tonumber(max))
	sld:SetDecimals(tonumber(decplace))
	sld:SizeToContents()
	sld:SetTall(32)
	sld:SetDark(true)

	parent:AddItem(sld)
	return sld
end
configstuff.CList = vgui.Create( "DCategoryList", configstuff )
configstuff.CList:Dock(FILL)

configstuff.chat = configstuff.CList:Add("Chat")
	configstuff.chat:SetExpanded(false)
	configstuff.chat:SetPadding(0)
	configstuff.chat.list = vgui.Create( "DPanelList", configstuff.chat )
		configstuff.chat.list:SetSpacing(0)
		configstuff.chat.list:SetPadding(0)
		configstuff.chat.list:EnableHorizontal(false)
		configstuff.chat.list:EnableVerticalScrollbar(true)
		configstuff.chat:SetContents(configstuff.chat.list)

	-- richtext font
	-- textentry font
	--AddSettingsSpacer( configstuff.game.list )
	AddSettingsOption( configstuff.chat.list, "Timestamps (chat history)", "hnchat_timestamps", 1, 0 )
	AddSettingsOption( configstuff.chat.list, "24 Hour Timestamps", "hnchat_timestamps_24hr", 1, 0 )
	AddSettingsSpacer( configstuff.chat.list )
	if chatsounds then 
		AddSettingsOption( configstuff.chat.list, "Sounds on chat", "chatsounds_enabled", 1, 0 )
		AddSettingsSpacer( configstuff.chat.list )
		AddSettingsOption( configstuff.chat.list, "Autocomplete chat sounds", "chatsounds_autocomplete", 1, 0 )
	end
	AddSettingsSpacer( configstuff.chat.list )
	AddSettingsOption( configstuff.chat.list, "> Green text", "hnchat_greentext", 1, 0 )
	AddSettingsOption( configstuff.chat.list, "Highlight messages that mention you", "hnchat_highlight", 1, 0 )
--[[configstuff.chathud = configstuff.CList:Add("Chat HUD")
	configstuff.chathud:SetExpanded(false)
	configstuff.chathud:SetPadding(0)]]
configstuff.audio = configstuff.CList:Add("Audio")
	configstuff.audio:SetExpanded(false)
	configstuff.audio:SetPadding(0)
	configstuff.audio.list = vgui.Create( "DPanelList", configstuff.audio )
		configstuff.audio.list:SetSpacing(0)
		configstuff.audio.list:SetPadding(0)
		configstuff.audio.list:EnableHorizontal(false)
		configstuff.audio.list:EnableVerticalScrollbar(true)
		configstuff.audio:SetContents(configstuff.audio.list)

	AddSettingsOption( configstuff.audio.list, "Out of game mute", "snd_mute_losefocus", 1, 0 )
	if chatsounds then AddSettingsOption( configstuff.audio.list, "Sounds on chat", "chatsounds_enabled", 1, 0 ) end
	AddSettingsSlider( configstuff.audio.list, "Global Volume", "volume", 2, 0, 1 )
	AddSettingsSlider( configstuff.audio.list, "PlayX Media Volume", "playx_volume", 2, 0, 100 )
	-- slider for media player volume
	if pac then AddSettingsSlider( configstuff.audio.list, "PAC Volume", "pac_ogg_volume", 2, 0, 1 ) end
	if chatsounds then AddSettingsSlider( configstuff.audio.list, "Chatsounds Volume", "chatsounds_volume", 2, 0, 1 ) end
configstuff.graphics = configstuff.CList:Add("Performance / Graphics")
	configstuff.graphics:SetExpanded(false)
	configstuff.graphics:SetPadding(0)
	configstuff.graphics.list = vgui.Create( "DPanelList", configstuff.graphics )
		configstuff.graphics.list:SetSpacing(0)
		configstuff.graphics.list:SetPadding(0)
		configstuff.graphics.list:EnableHorizontal(false)
		configstuff.graphics.list:EnableVerticalScrollbar(true)
		configstuff.graphics:SetContents(configstuff.graphics.list)

	AddSettingsOption( configstuff.graphics.list, "Draw own shadow", "cl_drawownshadow", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Shadows (FPS!!!)", "r_shadows", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Disable Player Sprays", "cl_playerspraydisable", 1, 0 )
	AddSettingsSpacer(configstuff.graphics.list)
	AddSettingsOption( configstuff.graphics.list, "Water Reflection", "r_WaterDrawReflection", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Water Refraction", "r_WaterDrawRefraction", 1, 0 )
	AddSettingsSpacer(configstuff.graphics.list)
	if pac then AddSettingsOption( configstuff.graphics.list, "PAC (player outfits)", "pac_enable", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Sounds", "pac_enable_sound", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Increase FPS", "pac_suppress_frames", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Download Textures", "pac_enable_urltex", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Download Models", "pac_enable_urlobj", 1, 0 )
		AddSettingsSlider( configstuff.graphics.list, "    Draw Distance", "pac_draw_distance", 2, 0, 10000 )
	end
configstuff.dms = configstuff.CList:Add( "PM" )
	configstuff.dms:SetExpanded(false)
	configstuff.dms:SetPadding(0)
	configstuff.dms.list = vgui.Create( "DPanelList", configstuff.dms )
		configstuff.dms.list:SetSpacing(0)
		configstuff.dms.list:SetPadding(0)
		configstuff.dms.list:EnableHorizontal(false)
		configstuff.dms.list:EnableVerticalScrollbar(true)
		configstuff.dms:SetContents(configstuff.dms.list)

	AddSettingsOption( configstuff.dms.list, "Disable", "hnchat_pm_disable", 1, 0 )
	AddSettingsOption( configstuff.dms.list, "Friends only", "hnchat_pm_friendsonly", 1, 0 )
	AddSettingsSpacer(configstuff.dms.list)
	AddSettingsOption( configstuff.dms.list, "PM in chat", "pm_hud", 1, 0 )
	AddSettingsSpacer(configstuff.dms.list)
	AddSettingsOption( configstuff.dms.list, "Notify Text", "pm_hud_notify", 1, 0 )
	AddSettingsOption( configstuff.dms.list, "Notify Sound", "pm_hud_notify_sound", 1, 0 )
	AddSettingsSpacer(configstuff.dms.list)
	AddSettingsOption( configstuff.dms.list, "Team chat -> PM", "hnchat_pmmode", 1, 0 )
	if chatsounds then AddSettingsOption( configstuff.dms.list, "Chatsounds", "pm_chatsounds", 1, 0 ) end
	AddSettingsSpacer(configstuff.dms.list)
	AddSettingsOption( configstuff.dms.list, "(1) Highlight GMod Window on PM", "pm_notify_window", 1, 0 )
	AddSettingsOption( configstuff.dms.list, "(2) Highlight GMod Window on PM (Friends only)", "pm_notify_window", 2, 0 )
configstuff.game = configstuff.CList:Add("Game")
	configstuff.game:SetExpanded(false)
	configstuff.game:SetPadding(0)
	configstuff.game.list = vgui.Create( "DPanelList", configstuff.game )
		configstuff.game.list:SetSpacing(0)
		configstuff.game.list:SetPadding(0)
		configstuff.game.list:EnableHorizontal(false)
		configstuff.game.list:EnableVerticalScrollbar(true)
		configstuff.game:SetContents(configstuff.game.list)

	AddSettingsOption( configstuff.game.list, "Thirdperson", "ctp", 0, 0 )
	AddSettingsOption( configstuff.game.list, "Hints", "cl_showhints", 0, 0 )
	AddSettingsSpacer( configstuff.game.list )
	AddSettingsOption( configstuff.game.list, "ShowFPS 1", "cl_showfps", 1, 0 )
	AddSettingsOption( configstuff.game.list, "ShowFPS 2", "cl_showfps", 2, 0 )
	AddSettingsSpacer( configstuff.game.list )
	AddSettingsOption( configstuff.game.list, "Developer 1", "developer", 1, 0 )
	AddSettingsOption( configstuff.game.list, "Developer 2", "developer", 2, 0 )
	AddSettingsSpacer( configstuff.game.list )
	AddSettingsOption( configstuff.game.list, "Net Graph 1", "net_graph", 1, 0 )
	AddSettingsOption( configstuff.game.list, "Net Graph 2", "net_graph", 2, 0 )
	AddSettingsOption( configstuff.game.list, "Net Graph 3", "net_graph", 3, 0 )
	AddSettingsOption( configstuff.game.list, "Net Graph 4", "net_graph", 4, 0 )
configstuff.media = configstuff.CList:Add( "Media Player" )
	configstuff.media:SetExpanded(false)
	configstuff.media:SetPadding(0)
	configstuff.media.list = vgui.Create( "DPanelList", configstuff.media )
		configstuff.media.list:SetSpacing(0)
		configstuff.media.list:SetPadding(0)
		configstuff.media.list:EnableHorizontal(false)
		configstuff.media.list:EnableVerticalScrollbar(true)
		configstuff.media:SetContents(configstuff.media.list)

	AddSettingsOption( configstuff.media.list, "Enable (PlayX)", "playx_enabled", 1, 0 )
	--AddSettingsOption( configstuff.media.list, "Distance autoplay (PlayX, Friends only)", "playx_proximity_enable", 2, 0 )
	AddSettingsSpacer( configstuff.media.list )
	AddSettingsOption( configstuff.media.list, "Distance Volume (PlayX)", "playx_volume_distance", 1, 0 )
	-- slider for playx volume
	-- slider for media player volume

return configstuff