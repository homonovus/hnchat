local dmtag = "hnchat_dm"

if SERVER then
	util.AddNetworkString(dmtag)
	net.Receive(dmtag, function(len, ply)
		local target = net.ReadEntity()
		local txt = net.ReadString()

		--for k, v in next, plys do
			if not target:IsPlayer() then return end--table.remove(plys, k) end
		--end

		net.Start( dmtag, false )
			net.WriteEntity(ply)
			net.WriteString(txt)
		net.Send(target)
	end )

	return
end

if not hnchat then return end

local hnchat_pm_disable = CreateClientConVar( "hnchat_pm_disable", 0 )
local hnchat_pm_friendsonly = CreateClientConVar( "hnchat_pm_friendsonly", 0 )
local hnchat_pmmode = CreateClientConVar( "hnchat_pmmode", 0 )
local pm_chatsounds = CreateClientConVar( "pm_chatsounds", 0 )
local pm_hud = CreateClientConVar( "pm_hud", 0 )
local pm_hud_notify = CreateClientConVar( "pm_hud_notify", 0 )
local pm_hud_notify_sound = CreateClientConVar( "pm_hud_notify_sound", 0 )
local pm_notify_window = CreateClientConVar( "pm_notify_window", 0 )
concommand.Add( "pm", function(ply, cmd, args)
	if not args or not args[1] or args[1] == ""or not player.FindByName(args[1]) then
		Msg("player not found\n")
	else
		local txt = ""
		local ply = player.FindByName(args[1])
		for k, v in next, args do txt = k ~= 1 and (txt..(k ~= 2 and " " or "")..v) or txt end
		dmPlayer(ply, txt)
	end
end, function(cmd, args)
	args = args:Trim()
	local auto = {}

	for k, v in next, player.GetAll() do
		if string.find( string.lower(v:UndecorateNick()), string.lower(args) ) then table.insert( auto, cmd.." \""..v:UndecorateNick().."\"" ) end
	end
	return auto
end)

function hnchat.addDM(ply)
	if not IsValid(ply) then return end
	local sid = ply:SteamID()
	if IsValid(dmstuff.tabs.tabs[sid]) then return end

	dmstuff.tabs.tabs[sid] = vgui.Create("RichText")
	dmstuff.tabs.tabs[sid]:Dock(FILL)
	dmstuff.tabs.tabs[sid].PerformLayout = function( self )
		self:SetFontInternal( GetConVar("hnchatbox_history_font"):GetString() )
		self:SetFGColor(Color( 255, 255, 255, 128))
	end
	dmstuff.tabs.tabs[sid].Paint = function( self, w ,h )
		draw.RoundedBox( 0, 0, 0, w, h, Color(37,37,37,196))
	end
	dmstuff.tabs.tabs[sid].Player = ply
	dmstuff.tabs.tabs[sid].oldThink = dmstuff.tabs.tabs[sid].Think
	dmstuff.tabs.tabs[sid].Think = function(self)
		if self:IsVisible() then
			self.unread = false
			--[[if self:GetParent():IsVisible() then
				dmstuff.unread = (dmstuff.unread >= 1 and dmstuff.unread - 1 or 0)
			end]]
		end
	end

	local t = dmstuff.tabs:AddSheet( ply:UndecorateNick(), dmstuff.tabs.tabs[sid], nil, false, false, ply:UndecorateNick() )
	t.Tab.DoClick = function(self)
		self:GetPropertySheet():SetActiveTab( self )
		self:GetPanel():SetVisible(true)
	end
	t.Tab.DoRightClick = function(self)
		dmstuff.tabs:CloseTab( t.Tab, true )
		dmstuff.tabs.tabs[sid] = nil
	end
	t.Tab.GetTabHeight = function() return 20 end
	t.Tab.Paint = function(self, w, h)
		local col, textcol = Color(0,0,0,0), Color(81,81,81)

		if self:IsActive() then
			col = Color(225,228,232)
		end

		if self:IsHovered() then
			col = Color(208,208,208)
			textcol = Color(96,42,180)
		end

		if self:IsDown() then
			textcol = color_white
		end

		if self:GetPanel().unread then
			local r = TimedCos( 1, 196, 222, 1 )
			local g = TimedCos( 1, 196, 222, 1 )
			col = Color(r,g,222)
		end

		surface.SetDrawColor(col)
		surface.DrawRect(0,0,w,h)
		draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if self:IsActive() then
			surface.SetDrawColor(Color(116,170,232))
			surface.DrawRect( 0, h-2, w, 2 )
		end

		return true
	end

	hnchat.AddText(dmstuff.tabs.tabs[sid], color_white, "Chatting with ", ply)
end
player.FindByName = player.FindByName or function(name)
	for k, v in next, player.GetAll() do
		if string.find( string.lower(v:UndecorateNick()), string.lower(name) ) then return v end
	end
end
function dmPlayer(ply, txt)
	if hnchat_pm_disable:GetBool() or not IsValid(ply) then return end

	if not dmstuff.tabs.tabs[ply:SteamID()] then hnchat.addDM(ply) end

	chat.AddText(Color(200,100,100), "[", color_white, "PM to ", ply, Color(200,100,100), "] ", LocalPlayer(), color_white, ": ", txt)
	hnchat.AddText( dmstuff.tabs.tabs[ply:SteamID()], LocalPlayer(), color_white, ": ", txt )

	if pm_chatsounds:GetBool() then RunConsoleCommand("saysound", txt) end
	net.Start( dmtag, false )
		net.WriteEntity(ply)
		net.WriteString(txt)
	net.SendToServer()
end

net.Receive(dmtag, function(len)
	if hnchat_pm_disable:GetBool() then return end
	local ply = net.ReadEntity()
	local txt = net.ReadString()
	if hnchat_pm_friendsonly:GetBool() and not (ply:GetFriendStatus() == "friend") then return end

	if not dmstuff.tabs.tabs[ply:SteamID()] then hnchat.addDM(ply) end

	hnchat.AddText(dmstuff.tabs.tabs[ply:SteamID()], ply, color_white, ": "..txt )
	if not dmstuff.tabs.tabs[ply:SteamID()]:IsVisible() or not hnchat.derma.Frame:IsVisible() then
		dmstuff.tabs.tabs[ply:SteamID()].unread = true
		--dmstuff.unread = dmstuff.unread + 1
		if pm_hud_notify_sound:GetBool() then surface.PlaySound("friends/message.wav") end
		if (pm_hud_notify:GetBool() and not pm_hud:GetBool()) then chat.AddText(Color(200,100,100),"[[ ", color_white, "PM From ", ply, Color(200,100,100), " ]]") end
		if (pm_hud:GetBool() and not pm_hud_notify:GetBool()) or (pm_hud_notify:GetBool() and pm_hud:GetBool()) then chat.AddText(Color(200,100,100),"[", color_white, "PM", Color(200,100,100), "] ", ply, color_white, ": "..txt) end
	end
	if (pm_notify_window:GetInt() >= 2 and (ply:GetFriendStatus() == "friend")) or pm_notify_window:GetInt() == 1 then
		if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
	end
end)

concommand.Add( "hnchat_open_pm",function() 
	hnchat.openChatbox("PM")
	dmstuff.TextEntry:RequestFocus()
end)

cvars.AddChangeCallback( "hnchatbox_history_font",function(cmd, old, new)
	for k, v in next, dmstuff.tabs.tabs do
		v:PerformLayout()
	end
end)
cvars.AddChangeCallback( "hnchatbox_font_input", function( cmd, old, new)
	if new == old then return end

	dmstuff.TextEntry:SetFont(new)
	dmstuff.TextEntry:ApplySchemeSettings()

	return
end)

dmstuff = vgui.Create("DPanel")
dmstuff.Paint = function() return false end
--dmstuff.unread = 0
dmstuff.tabs = vgui.Create( "DPropertySheet", dmstuff )
dmstuff.tabs:Dock(FILL)
dmstuff.tabs:SetFadeTime(0)
dmstuff.tabs:SetPadding(0)
dmstuff.tabs.Paint = function() end
function dmstuff.tabs:CloseTab(tab, bRemovePanelToo )
		for k, v in next, self.Items do
			if ( v.Tab != tab ) then continue end
			table.remove( self.Items, k )
		end
		for k, v in next, self.tabScroller.Panels do
			if ( v != tab ) then continue end
			table.remove( self.tabScroller.Panels, k )
		end

		self.tabScroller:InvalidateLayout( true )

		if ( tab == self:GetActiveTab() ) then
			self.m_pActiveTab = self.Items[#self.Items] ~= nil and self.Items[#self.Items].Tab or nil
		end

		local pnl = tab:GetPanel()

		if ( bRemovePanelToo ) then
			pnl:Remove()
		end

		tab:Remove()

		self:InvalidateLayout( true )

		return pnl
end
function dmstuff.tabs:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )
	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	Sheet.Name = label

	Sheet.Tab = vgui.Create( "DTab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )

	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetPos( self:GetPadding(), 20 + self:GetPadding() )
	Sheet.Panel:SetVisible( false )
	panel:SetParent( self )

	table.insert( self.Items, Sheet )

	--[[if ( !self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( false )
	end]]

	self.tabScroller:AddPanel( Sheet.Tab )

	return Sheet
end
dmstuff.tabs.tabs = {}

dmstuff.topbar = vgui.Create( "DPanel", dmstuff )
dmstuff.topbar:Dock(TOP)
dmstuff.topbar:DockPadding(1,1,1,1)

dmstuff.tabs.tabScroller:SetParent(dmstuff.topbar)
dmstuff.tabs.tabScroller.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255) )
end
dmstuff.tabs.tabScroller:Dock(FILL)
dmstuff.tabs.tabScroller:SetOverlap(-4)

dmstuff.newbutton = vgui.Create( "DButton", dmstuff.topbar )
dmstuff.newbutton:SetSize(122,22)
dmstuff.newbutton:Dock(LEFT)
dmstuff.newbutton:SetText("New discussion with...")
dmstuff.newbutton.DoClick = function(self)
	local plys = player.GetAll()
	table.sort( plys, function(a,b) return a:UndecorateNick():Trim():lower() < b:UndecorateNick():Trim():lower() end)
	local menu = DermaMenu()
	for k, v in pairs(plys) do
		if not dmstuff.tabs.tabs[v:SteamID()] then
			menu:AddOption( v:UndecorateNick():Trim(), function()
				hnchat.addDM(v)
			end ):SetIcon((v:GetFriendStatus()=="friend" and "icon16/user_green.png"))
		end
	end
	menu.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then
			self:Remove()
		end
	end
	menu:Open()
end

dmstuff.TextEntry = vgui.Create( "DTextEntry", dmstuff )
dmstuff.TextEntry:Dock(BOTTOM)
local w,h = dmstuff.TextEntry:GetSize()
dmstuff.TextEntry:SetSize(w,14)
dmstuff.TextEntry.OldThink = dmstuff.TextEntry.Think
dmstuff.TextEntry.Paint = function( self, w ,h )
	local col = self.HistoryPos == 0 and color_white or Color( 241, 201, 151, 255 )
	draw.RoundedBox( 0, 0, 0, w, h, col )
	self:DrawTextEntryText( Color( 0, 0, 0, 255 ), Color( 24, 131, 255, 255 ), Color( 0, 0, 0, 255 ))
	return false
end
dmstuff.TextEntry.OnKeyCodeTyped = function( self, key )
	if key == KEY_ENTER then
		local str = self:GetValue():Trim()

		self:AddHistory(str)
		self:SetText("")
		--hnchat.closeChatbox()
		if str ~= "" and dmstuff.tabs:GetActiveTab() ~= nil then
			dmPlayer( dmstuff.tabs:GetActiveTab():GetPanel().Player, str )
		end

		self.HistoryPos = 0
		return true
	elseif key == KEY_UP then
		self.HistoryPos = self.HistoryPos - 1
		self:UpdateFromHistory()
		return true
	elseif key == KEY_DOWN then
		self.HistoryPos = self.HistoryPos + 1
		self:UpdateFromHistory()
		return true
	end
end

local t = hnchat.derma.tabs:AddSheet( "PM", dmstuff, "icon16/group.png", false, false, "PM" )

--[[t.Tab.Paint = function(self, w, h)
	if dmstuff.unread > 0 and not self:IsActive() then
		local col= Color(0,0,0,0)
		local a = math.Clamp(math.abs(math.cos(RealTime())*255),0,255)--TimedCos( 2, 0, 255, 3 )
		col = Color(166,187,207,a)

		surface.SetDrawColor(col)
		surface.DrawRect(0,0,w,h)
	else
		derma.SkinHook("Paint","Tab",self,w,h)
	end
end]]

return t