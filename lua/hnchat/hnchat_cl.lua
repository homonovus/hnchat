--if hnchat then hnchat.UnLoad() end

local hnchat_disable = CreateClientConVar("hnchat_disable",1) -- disable by default bc people might not want it

if hnchat_disable:GetBool() then return end

hook.Add( "Initialize", "hnchat", function()
	hook.Remove( "Initialize", "hnchat" )

	hnchat = hnchat or {}
	oldchatgui = oldchatgui or chatgui
	local hnchat_timestamps = CreateClientConVar( "hnchat_timestamps", 1 )
	local hnchat_timestamps_24hr = CreateClientConVar( "hnchat_timestamps_24hr", 1 )
	local hnchat_greentext = CreateClientConVar( "hnchat_greentext", 1 )
	local hnchat_highlight = CreateClientConVar( "hnchat_highlight", 1 )

	function hnchat.tofull()
		hnchat.isFull = true
		local x, y = hnchat.derma.Frame:GetPos()
		local w, h = hnchat.derma.Frame:GetSize()
		hnchat.derma.Frame:SetCookie("x",x)
		hnchat.derma.Frame:SetCookie("y",y)
		hnchat.derma.Frame:SetCookie("w",w)
		hnchat.derma.Frame:SetCookie("h",h)

		hnchat.derma.Frame:SetSize(ScrW(), ScrH())
		hnchat.derma.Frame:SetPos(0,0)
		hnchat.derma.Frame:SetDraggable( false )

		hnchat.derma.FSButton.DoClick = hnchat.towin
	end
	function hnchat.towin()
		hnchat.isFull = false
		local x = hnchat.derma.Frame:GetCookie("x",x)
		local y = hnchat.derma.Frame:GetCookie("y",y)
		local w = hnchat.derma.Frame:GetCookie("w",w)
		local h = hnchat.derma.Frame:GetCookie("h",h)

		hnchat.derma.Frame:SetDraggable( true )
		hnchat.derma.Frame:SetPos(x,y)
		hnchat.derma.Frame:SetSize(w,h)

		hnchat.derma.FSButton.DoClick = hnchat.tofull
	end
	function hnchat.closeChatbox()
		hnchat.derma.Frame:SetMouseInputEnabled( false )
		hnchat.derma.Frame:SetKeyboardInputEnabled( false )
		gui.EnableScreenClicker( false )
		hnchat.derma.Frame:SetVisible( false )

		gamemode.Call( "FinishChat" )

		hnchat.derma.chat.TextEntry:SetText("")
		gamemode.Call( "ChatTextChanged", "" )
	end
	function hnchat.openChatbox(mode)
		hnchat.derma.Frame:MakePopup()
		hnchat.derma.Frame:SetVisible(true)

		hnchat.derma.tabs:SwitchToName(mode)

		gamemode.Call("StartChat")
		gamemode.Call( "ChatTextChanged", "" )
	end

	local PLAYER = FindMetaTable("Player")
	function PLAYER:UndecorateNick()
		local name_nod = self:Nick()
		name_nod = string.gsub(name_nod,"<hsv=(.-)>","")
		name_nod = string.gsub(name_nod,"</hsv>","")
		name_nod = string.gsub(name_nod,"<color=(.-)>","")
		name_nod = string.gsub(name_nod,"</color>","")
		name_nod = string.gsub(name_nod,"%^(%d+%.?%d*)","")
		name_nod = string.gsub(name_nod,"<c=(.-)>","")
		name_nod = string.gsub(name_nod,"</c>","")
		name_nod = string.gsub(name_nod,"<background=(.-)>","")
		name_nod = string.gsub(name_nod,"</background>","")
		return name_nod
	end
	function draw.OutlinedBox( x, y, w, h, thickness, clr )
		surface.SetDrawColor( clr )
		for i=0, thickness - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end
	oldSay = oldSay or Say
	function Say( txt, team )
		if util.NetworkStringToID( "hnnchat_say_send" ) ~= 0 then
			net.Start( "hnchat_say", false )
				net.WriteString(txt)
				net.WriteBool(team)
			net.SendToServer()
		else
			LocalPlayer():ConCommand( "say" .. (team == true and "_team" or "") .. " " .. txt )
		end
	end
	function SayLocal(txt)
		if util.NetworkStringToID("hnchat_local_send") == 0 then return end

		local meme = { Color(255,0,0), "(Local @ " }
		local sphere = ents.FindInSphere( LocalPlayer():GetPos(), 196 )

		net.Start( "hnchat_local_send", false )
			local plys = {}
			for k, v in next, sphere do
				if v:IsPlayer() and v ~= LocalPlayer() then
					table.insert( plys, v )
				end
			end
			net.WriteTable( plys )
			net.WriteString( txt )
		net.SendToServer()

		for k, v in next, plys do
			if v ~= LocalPlayer() then
				if k ~= #plys then
					table.insert( meme, v )

					table.insert( meme, Color(255,255,255) )
					table.insert( meme, ", " )
				else
					table.insert( meme, v )
				end
			end
		end

		table.insert( meme, Color(255,0,0) )
		table.insert( meme, " )" )

		chat.AddText( unpack(meme) )
		chat.AddText( Color(24,161,35), "(Local) ", LocalPlayer(), color_white, ": " .. txt )
	end

	hnchat.derma = hnchat.derma or {}
		hnchat.derma.Frame = vgui.Create("DFrame")
		hnchat.derma.Frame:SetTitle("")
		hnchat.derma.Frame:SetDraggable(true)
		hnchat.derma.Frame:SetSizable(true)
		hnchat.derma.Frame:ShowCloseButton(false)
		hnchat.derma.Frame:SetScreenLock(true)
		hnchat.derma.Frame:SetMinimumSize( 200, 100 )
		hnchat.derma.Frame.Paint = function( self, w, h )
			draw.OutlinedBox( 0, 0, w, h, 1, Color( 32, 32, 32, 128) )
			surface.DrawRect( 0, 0, w, h )
			return false
		end
		hnchat.derma.Frame.oldThink = hnchat.derma.Frame.Think
		hnchat.derma.Frame.Think = function(self)
			if input.IsKeyDown(KEY_ESCAPE) then
				gui.HideGameUI()
				hnchat.closeChatbox()
			end
			hnchat.derma.Frame.oldThink(self)
		end
		hnchat.derma.Frame.OnKeyCodePressed = function( self, key )
			if key == KEY_F11 then hnchat.derma.FSButton.DoClick() end
		end
		hnchat.derma.Frame:DockPadding(5,4,5,1)

		hnchat.derma.Frame:SetCookieName("hnchat") -- cookies????
		local x = hnchat.derma.Frame:GetCookie("x", 20)
		local y = hnchat.derma.Frame:GetCookie("y", ScrH() - math.min(650, ScrH() - 350))
		local w = hnchat.derma.Frame:GetCookie("w", 600)
		local h = hnchat.derma.Frame:GetCookie("h", 350)
		hnchat.derma.Frame:SetPos(x,y)
		hnchat.derma.Frame:SetSize(w,h)

		chatgui = hnchat.derma.Frame -- chatsounds

	hnchat.derma.tabs = vgui.Create( "DPropertySheet", hnchat.derma.Frame )
	hnchat.derma.tabs:SetFadeTime(0)
	hnchat.derma.tabs:Dock(FILL)
	hnchat.derma.tabs:SetPadding(0)
	hnchat.derma.tabs.Paint = function() return false end
	hnchat.derma.tabs.tabScroller:SetCursor("sizeall")
	hnchat.derma.tabs.tabScroller:SetMouseInputEnabled(true)
	hnchat.derma.tabs.tabScroller.oldThink = hnchat.derma.tabs.tabScroller.Think
	hnchat.derma.tabs.tabScroller.Think = function(self)
		if hnchat.derma.Frame:IsActive() and self:IsHovered() then
			if input.IsMouseDown(MOUSE_LEFT) or input.IsMouseDown(MOUSE_RIGHT) then
				if not hnchat.derma.Frame:IsDragging() then
					hnchat.derma.Frame.Dragging = { gui.MouseX() - hnchat.derma.Frame.x, gui.MouseY() - hnchat.derma.Frame.y }
					hnchat.derma.Frame:MouseCapture(true)
				end
			else
				if not hnchat.derma.Frame:IsDragging() then
					hnchat.derma.Frame.Dragging = nil
					hnchat.derma.Frame:MouseCapture(false)
				end
			end
		end
		hnchat.derma.tabs.tabScroller.oldThink(self)
	end

	hnchat.derma.chat = vgui.Create("DPanel")
		hnchat.derma.chat.Paint = function() return false end
		hnchat.derma.chat.RichText = vgui.Create( "RichText", hnchat.derma.chat )
		hnchat.derma.chat.RichText:Dock(FILL)
		hnchat.derma.chat.RichText.Paint = function( self, w ,h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(22,22,22,196))
		end
		hnchat.derma.chat.RichText.PerformLayout = function( self )
			self:SetFontInternal( "DermaDefault" )
			self:SetFGColor(Color( 255, 255, 255, 128))
		end
		hnchat.derma.chat.RichText.ActionSignal = function( self, signalName, signalValue )
			if ( signalName == "TextClicked" ) then
					gui.OpenURL(signalValue)
			end
		end

		hnchat.derma.chat.message = vgui.Create( "DPanel", hnchat.derma.chat )
		hnchat.derma.chat.message:Dock(BOTTOM)
		local w,h = hnchat.derma.chat.message:GetSize()
		hnchat.derma.chat.message:SetSize(w,14)
		hnchat.derma.chat.TextEntry = vgui.Create( "DTextEntry", hnchat.derma.chat.message )
		hnchat.derma.chat.TextEntry:Dock(FILL)
		hnchat.derma.chat.TextEntry.OldThink = hnchat.derma.chat.TextEntry.Think
		hnchat.derma.chat.TextEntry.Think = function(self)
			gamemode.Call( "ChatTextChanged", self:GetValue() )
			self.OldThink(self)
		end
		hnchat.derma.chat.TextEntry.Paint = function( self, w ,h )
			local col = self.HistoryPos == 0 and Color(255,255,255,255) or Color(241,201,151,255)
			draw.RoundedBox( 0, 0, 0, w, h, col )
			self:DrawTextEntryText( Color(0,0,0,255), Color(24,131,255,255), Color(0,0,0,255) )
			return false
		end
		hnchat.derma.chat.TextEntry.OnKeyCodeTyped = function( self, key )
			if key == KEY_ENTER then
				local str = self:GetValue():Trim()

				self:AddHistory(str)
				self:SetText("")
				if str ~= "" then
					if hnchat.derma.chat.msgmode.curtype == 0 then
						Say( "\""..str.."\"", false )
					elseif hnchat.derma.chat.msgmode.curtype == 1 then
						Say( "\""..str.."\"", true )
					elseif hnchat.derma.chat.msgmode.curtype == 2 then
						SayLocal(str)
					elseif hnchat.derma.chat.msgmode.curtype == 3 then
						RunConsoleCommand( "saysound", str )
					elseif hnchat.derma.chat.msgmode.curtype == 4 then
						LocalPlayer():ConCommand("\""..str.."\"")
					else
						Say( "\""..str.."\"", false )
					end
				end

				self.HistoryPos = 0
				hnchat.closeChatbox()
				hnchat.derma.chat.msgmode.curtype = 0
				return true
			elseif key == KEY_UP then
				self.HistoryPos = self.HistoryPos - 1
				self:UpdateFromHistory()
				return true
			elseif key == KEY_DOWN then
				self.HistoryPos = self.HistoryPos + 1
				self:UpdateFromHistory()
				return true
			elseif key == KEY_TAB then
				if self:GetValue() == "" or not self:GetValue() then
					if input.IsControlDown() then
						hnchat.derma.chat.msgmode.curtype = hnchat.derma.chat.msgmode.curtype > 0 and hnchat.derma.chat.msgmode.curtype - 1 or #hnchat.derma.chat.msgmode.types
					else
						hnchat.derma.chat.msgmode.curtype = hnchat.derma.chat.msgmode.curtype < #hnchat.derma.chat.msgmode.types and hnchat.derma.chat.msgmode.curtype + 1 or 0
					end
				else
					local tab = hook.Run( "OnChatTab", self:GetValue() )

					if tab and isstring(tab) and tab ~= self:GetValue() then
						self:SetText(tab)
					end

					timer.Simple(0, function() self:RequestFocus() self:SetCaretPos( #self:GetText() ) end)
				end

				return true
			end
		end
		hnchat.derma.chat.msgmode = vgui.Create("DButton", hnchat.derma.chat.message )
		hnchat.derma.chat.msgmode:Dock(LEFT)
		hnchat.derma.chat.msgmode.curtype = 0
		hnchat.derma.chat.msgmode.types = {
				[0] = {
					["name"] = "Say",
					["icon"] = "icon16/world",
					["size"] = {
						["x"] = 31,
						["y"] = 16
					}
				},
				[1] = {
					["name"] = "Say (TEAM)",
					["icon"] = "icon16/world_link",
					["size"] = {
						["x"] = 69,
						["y"] = 16
					}
				},
				[2] = {
					["name"] = "local chat",
					["icon"] = "icon16/transmit_blue",
					["size"] = {
						["x"] = 58,
						["y"] = 16
					}
				},
				[3] = {
					["name"] = "Voice",
					["icon"] = "icon16/phone_sound",
					["size"] = {
						["x"] = 38,
						["y"] = 16
					}
				},
				[4] = {
					["name"] = "Console",
					["icon"] = "icon16/application_xp_terminal",
					["size"] = {
						["x"] = 51,
						["y"] = 16
					}
				},
				[5] = {
					["name"] = "Language",
					["icon"] = "icon16/font",
					["size"] = {
						["x"] = 60,
						["y"] = 16
					}
				}
		}
		hnchat.derma.chat.msgmode.Think = function( self )
			self:SetText( self.types[self.curtype].name )
			self:SetSize( self.types[self.curtype].size.x, self.types[self.curtype].size.y)
		end
		hnchat.derma.chat.msgmode.DoClick = function( self )
			self.curtype = self.curtype < 5 and self.curtype + 1 or 0
			self:SetText( self.types[self.curtype].name )
			self:SetSize( self.types[self.curtype].size.x, self.types[self.curtype].size.y)
		end
		hnchat.derma.chat.msgmode.DoRightClick = function( self )
			local menu = DermaMenu()
			for i = 0, #self.types do
				menu:AddOption( self.types[i].name, function()
					self.curtype = i
				end ):SetIcon( self.types[i].icon .. ".png")
			end
			menu:Open()
		end

	--[[local files, dir = file.Find( "hnchat/modules/*", "LUA" )
	for k, v in next, files do
		local name = string.gsub( v, "%plua", "" )
		hnchat.derma[name] = include("hnchat/modules/" .. v)
		if name == "config" or name == "dms" or name == "lua" then
			table.remove( files, k )
		end
	end]]
	hnchat.derma.dms = include("hnchat/modules/dms.lua")
	hnchat.derma.lua = include("hnchat/modules/lua.lua")
	hnchat.derma.config = include("hnchat/modules/config.lua")

	hnchat.derma.tabs:AddSheet( "Global", hnchat.derma.chat, "icon16/comments.png", false, false, "Chat" )
	if hnchat.derma.dms then hnchat.derma.tabs:AddSheet( "PM", hnchat.derma.dms, "icon16/group.png", false, false, "PM" ) end
	local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer.Tab.Paint = function(self) return false end
		spacer.Tab:SetEnabled(false)
		spacer.Tab:SetCursor("arrow")
		local spacer2 = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer2.Tab.Paint = function(self) return false end
		spacer2.Tab:SetEnabled(false)
		spacer2.Tab:SetCursor("arrow")
	if hnchat.derma.lua then hnchat.derma.tabs:AddSheet( "Lua", hnchat.derma.lua, "icon16/page_edit.png", false, false, "Lua" ) end
	if hnchat.derma.config then hnchat.derma.tabs:AddSheet( "Settings", hnchat.derma.config, "icon16/wrench_orange.png", false, false, "Config" ) end

	--[[for k, v in next, files do
		local name = string.gsub( v, "%plua", "" )
		hnchat.derma.tabs:AddSheet( name, hnchat.derma[name], nil, false, false, name )
	end]]

	hnchat.derma.CloseButton = vgui.Create( "DButton", hnchat.derma.Frame )
	hnchat.derma.CloseButton:SetSize( 42, 16 )
	hnchat.derma.CloseButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(255,0,0) or Color(255,62,62)

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, false, true )
		draw.SimpleTextOutlined( "r", "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		return true
	end
	hnchat.derma.CloseButton.DoClick = function(self)
		hnchat.closeChatbox()
	end
	hnchat.derma.CloseButton.oldThink = hnchat.derma.CloseButton.Think
	hnchat.derma.CloseButton.Think = function(self)
		local x, y = self:GetParent():GetSize()
		self:SetPos( x - 46, 0 )
		self.oldThink(self)
	end

	hnchat.derma.FSButton = vgui.Create( "DButton", hnchat.derma.Frame )
	hnchat.derma.FSButton:SetText("")
	hnchat.derma.FSButton:SetSize( 24, 16 )
	hnchat.derma.FSButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(128,128,128) or Color(177,177,177)
		local symbol = hnchat.isFull and "2" or "1"

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, true, false )
		draw.SimpleTextOutlined(symbol, "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		return true
	end
	hnchat.derma.FSButton.oldThink = hnchat.derma.FSButton.Think
	hnchat.derma.FSButton.Think = function(self)
		local x, y = self:GetParent():GetSize()
		self:SetPos( x - 70, 0 )
		self.oldThink(self)
	end
	hnchat.derma.FSButton.DoClick = hnchat.tofull

	hnchat.AddText = function( self, ... )
		local tab = {...}
		self:AppendText("\n")

		if hnchat_timestamps:GetBool() then
			self:InsertColorChange( 119, 171, 218, 255 )
			self:AppendText( hnchat_timestamps_24hr:GetBool() and (os.date("%H:%M", os.time())) or (os.date("%I:%M %p", os.time())) )

			self:InsertColorChange( 255, 255, 255, 255 )
			self:AppendText(" - ")
		end

		if #tab == 1 and isstring(tab[1]) then
			self:AppendText(tab[1])
			self:AppendText("\n")

			return
		end

		for k, v in next, tab do
			if IsColor(v) or istable(v) then
				self:InsertColorChange(v.r, v.g, v.b, 255)
			elseif type(v) == "string"  then
				--[[if (v:find(LocalPlayer():Nick()) or v:find(LocalPlayer():UndecorateNick())) and hnchat_highlight:GetBool() then
					hnchat.derma.chat.RichText:InsertColorChange( 255, 90, 35, 255 )
				end]]

				--[[if v:sub(3, 3):find(">") and hnchat_greentext:GetBool() then
					hnchat.derma.chat.RichText:InsertColorChange( 46, 231, 46, 255)
				end]]

				local url = v:match("https?://[^%s%\"]+")
				local s,e = v:find("https?://[^%s%\"]+")

				if url then self:InsertClickableTextStart(url) end
				self:AppendText(v)
				self:InsertClickableTextEnd()
			elseif isentity(v) then
				if v:IsPlayer() then
					local col = GAMEMODE:GetTeamColor(v)
					self:InsertColorChange(col.r, col.g, col.b, 255)

					self:AppendText(v:UndecorateNick())
				else
					local name = (v.Name and isfunction(v.name) and v:Name()) or v.Name or v.PrintName or tostring(v)
					if v:EntIndex() == 0 then
						self:InsertColorChange(106, 90, 205, 255)
						name = "Console"
					end

					self:AppendText(name)
				end
			end
		end
	end

	oldChatAddText = oldChatAddText or chat.AddText
	function chat.AddText(...)
		hnchat.AddText( hnchat.derma.chat.RichText, ... )
		oldChatAddText(...)
	end

	net.Receive("hnchat_local_receive", function(len)
		local ply = net.ReadEntity()
		local txt = net.ReadString()

		chat.AddText( Color(24,161,35), "(Local) ", ply, color_white, ": " .. txt )
	end)

	hook.Add( "PlayerBindPress", "hnchat", function( ply, bind, pressed )
		if bind:find("messagemode2") then
			RunConsoleCommand("hnchat_open")
			hnchat.derma.chat.msgmode.curtype = 1
			return true
		elseif bind:find("messagemode") then
			RunConsoleCommand("hnchat_open")
			return true
		end
	end )
	concommand.Add( "hnchat_open",function() -- opens chat
		hnchat.openChatbox("Global")
		hnchat.derma.chat.TextEntry:RequestFocus()
	end)
	concommand.Add( "hnchat_open_local",function() -- opens chat in local
		RunConsoleCommand("hnchat_open")
		hnchat.derma.chat.msgmode.curtype = 2
	end)
	concommand.Add( "hnchat_open_mode",function()
		-- idk what this does lol
	end)
	concommand.Add( "hnchat_open_team",function() -- open chat in team
		RunConsoleCommand("hnchat_open")
		hnchat.derma.chat.msgmode.curtype = 1
	end)

	function hnchat.UnLoad()
		-- restore original functions
		chat.AddText = oldChatAddText
		--[[chat.GetChatBoxPos = oldPos
		chat.GetChatBoxSize = oldSize
		chat.Open = oldOpen
		chat.Close = oldClose]]
		Say = oldSay

		-- set old functions to nil for whatever reason because im paranoid
		oldChatAddText = nil
		oldPos = nil
		oldSize = nil
		oldOpen = nil
		oldClose = nil
		oldSay = nil

		-- unhook
		hook.Remove( "ChatText", "hnchat" )
		hook.Remove( "PlayerBindPress", "hnchat" )
		hook.Remove( "OnPlayerChat", "hnchat" )

		-- empty
		hnchat = nil
		chatgui = oldchatgui or nil
		oldchatgui = nil
	end

	hnchat.closeChatbox()
end)
