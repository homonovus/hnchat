if not hnchat then return end

if SERVER then return end

surface.CreateFont("ComicSans",{
    font = "Comic Sans MS",
    size = 16
})

do
	local chathud_enable = CreateClientConVar( "chathud_enable", 1 )
	local chathud_height = CreateClientConVar( "chathud_height", 0.79 )
	local chathud_width = CreateClientConVar( "chathud_width", 0.8 )
end

concommand.Add( "hnchat_open_config", function() -- opens config panel
	hnchat.openChatbox("Settings")
end)

local playx = GetConVar("playx_enabled")
local mediaplayer = GetConVar("mediaplayer_volume")

local configstuff = vgui.Create("DPanel")

configstuff.list = vgui.Create("DPanelList", configstuff)
configstuff.list:Dock(FILL)
configstuff.list:EnableVerticalScrollbar(true)
local cfonts = {
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

local self = configstuff
local this = configstuff.list

local function HEAD(txt)
	local grp = vgui.Create( "DCollapsibleCategory" )

	grp:Dock(TOP)
	grp:DockMargin(0,0,0,0)
	grp:SetExpanded(false)
	grp:SetLabel(txt)
	this:AddItem(grp)
	
	self = grp

	grp.AddItem=function(grp,ctrl)
		ctrl:SetParent(grp)
		ctrl:Dock(TOP)
	end

	return grp
end

local function check( txt, cvar )
	if not GetConVar(cvar) then return end

	local opt = vgui.Create("DMenuOptionCVar")

	opt:SetText(txt)
	opt:SetToolTip("CVar: " .. cvar)
	opt:SetConVar(cvar)
	self:AddItem(opt)

	opt:GetParent().OpenSubMenu=function()end

	return opt
end

local function spacer(size)
	size = size or 8
	local pnl = vgui.Create( "DPanel", self )

	pnl.Paint = function() return true end
	pnl:SetTall(size)

	self:AddItem(pnl)
end

local function slider( txt, cvar, decplace, min, max )
	if not GetConVar(cvar) then return end
	local sld = vgui.Create("DNumSlider")

	sld:SetConVar(cvar)
	sld:SetText(tostring(txt))
	sld:SetMin(tonumber(min))
	sld:SetMax(tonumber(max))
	sld:SetDecimals(tonumber(decplace))
	sld:SetTall(32)
	sld:SetDark(true)
	sld:SizeToContents()

	self:AddItem(sld)
	return sld
end

local function fonts( txt, cvar )
	local chs = vgui.Create("DCollapsibleCategory", self)
	chs:SetLabel(txt)
	chs:SetExpanded(false)
	chs:DockMargin(10,0,10,0)
	chs.animSlide = Derma_Anim("Anim", chs, function(self, anim, delta, data)
		self:InvalidateLayout()
		self:GetParent():InvalidateLayout()
		self:GetParent():GetParent():InvalidateLayout()

		if anim.Started then
			data.To = self:GetTall()
		end

		if anim.Finished then return end
		if ( self.Contents ) then self.Contents:SetVisible( true ) end

		self:SetTall( Lerp( delta, data.From, data.To ) )
	end)

	for k,v in next, cfonts do
		local a = chs:Add(k)
		a:SetFont(k)
		if GetConVar(cvar):GetString() == k then a:SetSelected(true) end
		a.DoClick = function(self)
			RunConsoleCommand( cvar, self:GetText() )
		end
	end

	self:AddItem(chs)
	return chs
end

HEAD	"Chat".Header:SetIcon("icon16/comment.png")
	spacer()
	fonts		( "History Font", "hnchatbox_history_font" )
	fonts		( "Input Font", "hnchatbox_font_input" )
	spacer()
	check		( "Timestamps (chat history)", "hnchat_timestamps" )
	check		( "24 Hour Timestamps", "hnchat_timestamps_24hr" )
	spacer()
	check	( "Sounds on chat", "chatsounds_enabled" )
	spacer()
	check	( "Autocomplete chat sounds", "chatsounds_autocomplete" )
	spacer()
	check		( "> Green text", "hnchat_greentext" )
	check		( "Highlight messages that mention you", "hnchat_highlight" )
	check		( "Use Valve's chatbox", "hnchat_legacy" )
HEAD	"Chat HUD".Header:SetIcon("icon16/comments.png")
	check( "Custom chat HUD", "chathud_enable", 1, 0 )
	-- font editor button "Open Chat HUD Font Editor"
	--check( "Fade in new messages", "chathud_fadein", 1, 0 )
	check( "Use Valve's chatbox", "hnchat_legacy", 1, 0 )
	--check( "Chat in console", "chathud_callengine", 1, 0 )
	--spacer()
	--check( "Text decorations", "chathud_namedecoration", 1, 0 )
	--check( "HUD Image Viewer", "chathud_enable", 1, 0 )
	--spacer()
	--check( "Allow :you: substitution", "chathud_you", 1, 0 )
	--check( "Highlight messages including your nickname", "hnchat_highlight", 1, 0 )
	spacer()
	-- enable / disable markup tags
	-- image slide duration
	-- image hold duration
	slider( "Chat height", "chathud_height", 2, 0, 1 )
	slider( "Chat width", "chathud_width", 2, 0, 1 )
HEAD	"Audio".Header:SetIcon("icon16/sound.png")
	check		( "Out of game mute", "snd_mute_losefocus" )
	check		( "Sounds on chat", "chatsounds_enabled" )
	slider		( "Global Volume", "volume", 2, 0, 1 )
	slider		( "PlayX Media Volume", "playx_volume", 2, 0, 100 )
	slider		( "Media Player Volume", "mediaplayer_volume", 2, 0, 1 )
	slider		( "PAC Volume", "pac_ogg_volume", 2, 0, 1 )
	slider		( "Chatsounds Volume", "chatsounds_volume", 2, 0, 1 )
HEAD	"Performance / Graphics".Header:SetIcon("icon16/monitor.png")
	check		( "Draw own shadow", "cl_drawownshadow" )
	check		( "Shadows (FPS!!!)", "r_shadows" )
	check		( "Disable Player Sprays", "cl_playerspraydisable" )
	spacer(12)
	check		( "3D Sky", "r_3dsky" )
	spacer(12)
	check		( "Water Reflection", "r_WaterDrawReflection" )
	check		( "Water Refraction", "r_WaterDrawRefraction" )
	check		( "PAC (player outfits)", "pac_enable" )
	spacer(12)
	check		( "    Sounds", "pac_enable_sound" )
	check		( "    Increase FPS", "pac_suppress_frames" )
	check		( "    Download Textures", "pac_enable_urltex" )
	check		( "    Download Models", "pac_enable_urlobj" )
	slider		( "    Draw Distance", "pac_draw_distance", 2, 0, 10000 )
if hnchat.derma.dms then
HEAD	"PM".Header:SetIcon("icon16/group.png")
	check		( "Disable", "hnchat_pm_disable" )
	check		( "Friends only", "hnchat_pm_friendsonly" )
	spacer()
	check		( "PM in chat", "pm_hud" )
	spacer()
	check		( "Notify Text", "pm_hud_notify" )
	check		( "Notify Sound", "pm_hud_notify_sound" )
	spacer()
	check		( "Team chat -> PM", "hnchat_pmmode" )
	if chatsounds then
		check( "Chatsounds", "pm_chatsounds" )
	end
	spacer()
	check		( "(1) Highlight GMod Window on PM", "pm_notify_window" )
	check		( "(2) Highlight GMod Window on PM (Friends only)", "pm_notify_window" )
end
HEAD	"Game".Header:SetIcon("icon16/joystick.png")
	if ctp then
		local thirdperson = vgui.Create("DMenuOption" , self)
		thirdperson:SetText("Thirdperson")
		thirdperson:SetTooltip("Enable Thirdperson")
		function thirdperson.DoClick()
			thirdperson:ToggleCheck()
			if thirdperson:GetChecked() then ctp:Enable() else ctp:Disable() end
		end
		self:AddItem(thirdperson)
	end

	check		( "Hints", "cl_showhints" )
	spacer()
	check		( "ShowFPS 1", "cl_showfps" )
	check		( "ShowFPS 2", "cl_showfps" ):SetValueOn"2"
	spacer()
	check		( "Developer 1", "developer" )
	check		( "Developer 2", "developer" ):SetValueOn"2"
	spacer()
	check		( "Net Graph 1", "net_graph" )
	check		( "Net Graph 2", "net_graph" ):SetValueOn"2"
	check		( "Net Graph 3", "net_graph" ):SetValueOn"3"
	check		( "Net Graph 4", "net_graph" ):SetValueOn"4"
if PlayX or MediaPlayer then
HEAD	"Media Player".Header:SetIcon("icon16/music.png")
	check		( "Enable (PlayX)", "playx_enabled")
	check		( "Distance autoplay (PlayX)", "playx_proximity_enable", 1)
	check		( "Distance autoplay (PlayX, Friends only)", "playx_proximity_enable", 2)
	check		( "Distance autoplay (PlayX)", "mediaplayer_proximity", 1)
	check		( "Distance autoplay (PlayX, Friends only)", "mediaplayer_proximity", 2)
	spacer()
	check		( "Distance Volume (PlayX)", "playx_volume_distance", 1)
	check		( "Distance Volume (Mediaplayer)", "mediaplayer_volume_distance", 1)
	slider		( "Volume (PlayX)", "playx_volume", 2, 0, 100 )
	slider		( "Volume (Mediaplayer)", "mediaplayer_volume", 2, 0, 1 )
end

return hnchat.derma.tabs:AddSheet( "Settings", configstuff, "icon16/wrench_orange.png", false, false, "Config" )
