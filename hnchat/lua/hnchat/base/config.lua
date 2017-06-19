if not hnchat then return end

if SERVER then return end

surface.CreateFont("ComicSans",{
    font = "Comic Sans MS",
    size = 16
})

concommand.Add( "hnchat_open_config", function() -- opens config panel
	hnchat.openChatbox("Settings")
end)

local playx = GetConVar("playx_enabled")
local mediaplayer = GetConVar("mediaplayer_volume")

configstuff = vgui.Create("DPanel")
local fonts = {
	Trebuchet24 = true,
	ChatFont = true,
	TargetID = true,
	TargetIDSmall = true,
	BudgetLabel = true,
	Default = true,
	DefaultFixed = true,
	DermaDefault = true,
	closecaption_normal = true,
	hudselectiontext = true,
	ComicSans = true
}
local function AddSettingsGroup( parent, txt, icon )
	local grp = vgui.Create( "DCollapsibleCategory" )

	grp:Dock(TOP)
	grp:DockMargin(0,0,0,0)
	grp:SetExpanded(false)
	grp:SetLabel(txt)
	grp.Header:SetIcon(icon)

	grp.list = vgui.Create( "DPanelList", grp )
	grp.list:SetSpacing(0)
	grp.list:SetPadding(0)
	grp.list:EnableHorizontal(false)
	grp.list:EnableVerticalScrollbar(true)
	grp:SetContents(grp.list)

	parent:AddItem(grp)
	return grp
end
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

	pnl.Paint = function() return true end
	pnl:SetTall(12)

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
	sld:SetTall(32)
	sld:SetDark(true)
	sld:SizeToContents()

	parent:AddItem(sld)
	return sld
end
local function AddFontChooser( parent, txt, cvar )
	local chs = vgui.Create("DCollapsibleCategory", parent)
	chs:Dock(TOP)
	chs:DockMargin(4,0,4,0)
	chs:SetLabel(txt)
	chs:SetExpanded(false)

	for k,v in next, fonts do
		local a = chs:Add(k)
		a:SetFont(k)
		if GetConVar(cvar):GetString() == k then a:SetSelected(true) end
		a.DoClick = function(self)
			RunConsoleCommand( cvar, self:GetText() )
		end
	end

	chs:SizeToContents()
	parent:AddItem(chs)
	--[[chs.OnToggled = function( self, t )
		self:InvalidateLayout()
		self:GetParent():InvalidateLayout()
		parent:InvalidateLayout()
	end]]
	return chs
end
configstuff.CList = vgui.Create( "DCategoryList", configstuff )
configstuff.CList:Dock(FILL)
configstuff.CList:DockPadding(0,0,0,0)

configstuff.chat = AddSettingsGroup( configstuff.CList, "Chat", "icon16/comment.png" )
	AddFontChooser( configstuff.chat.list, "History Font", "hnchatbox_history_font" )
	AddFontChooser( configstuff.chat.list, "Input Font", "hnchatbox_font_input" )
	AddSettingsSpacer( configstuff.chat.list )
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
-- configstuff.chathud = AddSettingsGroup( configstuff.CList, "Chat HUD", "icon16/comments.png" )
configstuff.audio = AddSettingsGroup( configstuff.CList, "Audio", "icon16/sound.png")
	AddSettingsOption( configstuff.audio.list, "Out of game mute", "snd_mute_losefocus", 1, 0 )
	if chatsounds then AddSettingsOption( configstuff.audio.list, "Sounds on chat", "chatsounds_enabled", 1, 0 ) end
	AddSettingsSlider( configstuff.audio.list, "Global Volume", "volume", 2, 0, 1 )
	if playx then AddSettingsSlider( configstuff.audio.list, "PlayX Media Volume", "playx_volume", 2, 0, 100 ) end
	if mediaplayer then AddSettingsSlider( configstuff.audio.list, "Media Player Volume", "mediaplayer_volume", 2, 0, 1 ) end
	if pac then AddSettingsSlider( configstuff.audio.list, "PAC Volume", "pac_ogg_volume", 2, 0, 1 ) end
	if chatsounds then AddSettingsSlider( configstuff.audio.list, "Chatsounds Volume", "chatsounds_volume", 2, 0, 1 ) end
configstuff.graphics = AddSettingsGroup( configstuff.CList, "Performance / Graphics", "icon16/monitor.png")
	AddSettingsOption( configstuff.graphics.list, "Draw own shadow", "cl_drawownshadow", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Shadows (FPS!!!)", "r_shadows", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Disable Player Sprays", "cl_playerspraydisable", 1, 0 )
	AddSettingsSpacer(configstuff.graphics.list)
	AddSettingsOption( configstuff.graphics.list, "3D Sky", "r_3dsky", 1, 0 )
	AddSettingsSpacer(configstuff.graphics.list)
	AddSettingsOption( configstuff.graphics.list, "Water Reflection", "r_WaterDrawReflection", 1, 0 )
	AddSettingsOption( configstuff.graphics.list, "Water Refraction", "r_WaterDrawRefraction", 1, 0 )
	if pac then AddSettingsOption( configstuff.graphics.list, "PAC (player outfits)", "pac_enable", 1, 0 )
		AddSettingsSpacer(configstuff.graphics.list)
		if GetConVar("pac_enable_sound") then AddSettingsOption( configstuff.graphics.list, "    Sounds", "pac_enable_sound", 1, 0 ) end
		AddSettingsOption( configstuff.graphics.list, "    Increase FPS", "pac_suppress_frames", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Download Textures", "pac_enable_urltex", 1, 0 )
		AddSettingsOption( configstuff.graphics.list, "    Download Models", "pac_enable_urlobj", 1, 0 )
		AddSettingsSlider( configstuff.graphics.list, "    Draw Distance", "pac_draw_distance", 2, 0, 10000 )
	end
if hnchat.derma.dms then configstuff.dms = AddSettingsGroup( configstuff.CList, "PM", "icon16/group.png")
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
end
configstuff.game = AddSettingsGroup( configstuff.CList, "Game", "icon16/joystick.png")
	AddSettingsOption( configstuff.game.list, "Thirdperson", "ctp", 1, 0 )
	AddSettingsOption( configstuff.game.list, "Hints", "cl_showhints", 1, 0 )
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
if playx or mediaplayer then configstuff.media = AddSettingsGroup( configstuff.CList, "Media Player", "icon16/music.png")
	if playx then AddSettingsOption( configstuff.media.list, "Enable (PlayX)", "playx_enabled", 1, 0 ) end
	if GetConVar("playx_proximity_enable") then AddSettingsOption( configstuff.media.list, "Distance autoplay (PlayX)", "playx_proximity_enable", 1, 0 ) end
	if GetConVar("playx_proximity_enable") then AddSettingsOption( configstuff.media.list, "Distance autoplay (PlayX, Friends only)", "playx_proximity_enable", 2, 0 ) end
	if GetConVar("mediaplayer_proximity") then AddSettingsOption( configstuff.media.list, "Distance autoplay (PlayX)", "mediaplayer_proximity", 1, 0 ) end
	if GetConVar("mediaplayer_proximity") then AddSettingsOption( configstuff.media.list, "Distance autoplay (PlayX, Friends only)", "mediaplayer_proximity", 2, 0 ) end
	AddSettingsSpacer( configstuff.media.list )
	if GetConVar("playx_volume_distance") then AddSettingsOption( configstuff.media.list, "Distance Volume (PlayX)", "playx_volume_distance", 1, 0 ) end
	if GetConVar("mediaplayer_volume_distance") then AddSettingsOption( configstuff.media.list, "Distance Volume (Mediaplayer)", "mediaplayer_volume_distance", 1, 0 ) end
	if playx then AddSettingsSlider( configstuff.media.list, "Volume (PlayX)", "playx_volume", 2, 0, 100 ) end
	if mediaplayer then AddSettingsSlider( configstuff.media.list, "Volume (Mediaplayer)", "mediaplayer_volume", 2, 0, 1 ) end
end
return hnchat.derma.tabs:AddSheet( "Settings", configstuff, "icon16/wrench_orange.png", false, false, "Config" )