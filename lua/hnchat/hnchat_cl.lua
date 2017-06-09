if hnchat then hnchat.UnLoad() end

hook.Add( "Initialize", "hnchat", function()
	hook.Remove( "Initialize", "hnchat" )

	hnchat = hnchat or {}

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
		hnchat.derma.dms.TextEntry:SetText("")
		gamemode.Call( "ChatTextChanged", "" )
	end
	function hnchat.openChatbox(mode)
		hnchat.derma.Frame:MakePopup()
		hnchat.derma.Frame:SetVisible(true)

		hnchat.derma.tabs:SwitchToName(mode)

		gamemode.Call( "ChatTextChanged", "" )
	end
	function hnchat.addDM(ply)
		if not IsValid(ply) then return end
		local sid = ply:SteamID()
		if IsValid(hnchat.derma.dms.tabs.tabs[sid]) then return end

		hnchat.derma.dms.tabs.tabs[sid] = vgui.Create("RichText")
		hnchat.derma.dms.tabs.tabs[sid]:Dock(FILL)
		hnchat.derma.dms.tabs.tabs[sid].PerformLayout = function( self )
			self:SetFontInternal( "DermaDefault" )
			self:SetFGColor(Color( 255, 255, 255, 128))
		end
		hnchat.derma.dms.tabs.tabs[sid].Paint = function( self, w ,h )
			draw.RoundedBox( 0, 0, 0, w, h, Color(37,37,37,196))
		end
		hnchat.derma.dms.tabs.tabs[sid].AddText = function(...)
			local self = hnchat.derma.dms.tabs.tabs[sid]
			self:AppendText("\n")

			if hnchat.settings.chat.time_stamps.convar:GetBool() then
				self:InsertColorChange( 119, 171, 218, 255 )
				self:AppendText( hnchat.settings.chat.time_24h.convar:GetBool() and (os.date("%H:%M", os.time())) or (os.date("%I:%M %p", os.time())) )

				self:InsertColorChange( 255, 255, 255, 255 )
				self:AppendText(" - ")
			end

			for _, obj in pairs({...}) do
				if type(obj) == "table" then
					self:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
				elseif type(obj) == "string"  then
					--[[if (obj:find(LocalPlayer():Nick()) or obj:find(LocalPlayer():UndecorateNick())) and hnchat.config.chat.highlight.convar:GetBool() then
						self:InsertColorChange( 255, 90, 35, 255 )
					end]]

					--[[if obj:sub(3, 3):find(">") and hnchat.config.chat.greentext.convar:GetBool() then
						self:InsertColorChange( 46, 231, 46, 255)
					end]]

					local url = obj:match("https?://[^%s%\"]+")
					local s,e = obj:find("https?://[^%s%\"]+")

					if url then self:InsertClickableTextStart(url) end
					self:AppendText(obj)
					self:InsertClickableTextEnd()
				elseif obj:IsPlayer() then
					--local mark = markup.Parse(obj:Nick())
					--if (markup.blocks[1].colour.a == 255 and markup.blocks[1].colour.b == 255 and mark.blocks[1].colour.g == 255 and mark.blocks[1].colour.r == 255) then
						local col = GAMEMODE:GetTeamColor(obj)
					--[[else
						local col = markup.blocks[1].colour
					end]]

					self:InsertColorChange( col.r, col.g, col.b, 255 )
					self:AppendText( obj:UndecorateNick() )
				end
			end
		end
		hnchat.derma.dms.tabs.tabs[sid].Player = ply
		hnchat.derma.dms.tabs.tabs[sid].oldThink = hnchat.derma.dms.tabs.tabs[sid].Think
		hnchat.derma.dms.tabs.tabs[sid].Think = function(self)
			if self:IsVisible() then
				self.unread = false
			end
		end

		local t = hnchat.derma.dms.tabs:AddSheet( ply:UndecorateNick(), hnchat.derma.dms.tabs.tabs[sid], nil, false, false, ply:UndecorateNick() )
		t.Tab.DoRightClick = function(self)
			hnchat.derma.dms.tabs:CloseTab( t.Tab, true )
			hnchat.derma.dms.tabs.tabs[sid] = nil
		end
		t.Tab.GetTabHeight = function() return 20 end
		t.Tab.Paint = function(self, w, h)
			local col, textcol

			if self:IsActive() then
				col = Color(225,228,232)
				surface.SetDrawColor(Color(116,170,232))
				surface.DrawRect( 0, h-2, w, 2 )
			end

			if self:IsHovered() then
				col = Color(208,208,208)
				textcol = Color(96,42,180)
			elseif not self:IsHovered() then
				col = Color(0,0,0,0)
				textcol = Color(81,81,81)
			end

			if self:IsDown() then
				textcol = color_white
			end
			
			if hnchat.derma.dms.tabs.tabs[sid].unread then
				col = Color(math.Clamp(math.abs(math.sin(RealTime()*5)*255),225	,255),228,232)
			end

			surface.SetDrawColor(col)
			surface.DrawRect(0,0,w,h)
			draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			return true
		end

		hnchat.derma.dms.tabs.tabs[sid].AddText("Chatting with ", ply)
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
		local meme = { Color(255,0,0), "(Local @ " }
		local sphere = ents.FindInSphere( LocalPlayer():GetPos(), 196 )

		if util.NetworkStringToID("hnchat_local_send") == 0 then return end

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
	function dmPlayer(ply, txt)
		if util.NetworkStringToID("hnchat_dm_send") == 0 then return end

		net.Start( "hnchat_dm_send", false )
			net.WriteEntity(ply)
			net.WriteString(txt)
		net.SendToServer()
	end

	hnchat.settings = {
		chat = {
			time_stamps	= {
				label	= "Timestamps (chat history)",
				convar	= CreateClientConVar( "hnchat_timestamps", 1 ),
				desc	= "Display timestamps in chatbox",
			},
			time_24h	= {
				label	= "24 Hour Timestamps",
				convar	= CreateClientConVar( "hnchat_timestamps_24hr", 1 ),
				desc	= "Display 24 hour time in timestamps",
			},
			greentext	= {
				label	= "> Green text",
				convar	= CreateClientConVar( "hnchat_greentext", 1 ),
				desc	= "> implying you dont know what greentext is",
			},
			highlight	= {
				label	= "Highlight messages that mention you",
				convar	= CreateClientConVar( "hnchat_highlight", 1 ),
				desc	= "Messages will be coloured orange",
			},
		},
		debug = true,
	}

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

		--chatgui = hnchat.derma.Frame -- chatsounds

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

	hnchat.derma.chatpanel = vgui.Create("DPanel")
	hnchat.derma.dmpanel = vgui.Create("DPanel")
	hnchat.derma.luapanel = vgui.Create("DPanel")
	hnchat.derma.configpanel = vgui.Create("DPanel")
	hnchat.derma.chatpanel.Paint = function() return false end
	hnchat.derma.dmpanel.Paint = function() return false end
	hnchat.derma.luapanel.Paint = function() return false end

	hnchat.derma.chat = hnchat.derma.chat or {}
		hnchat.derma.chat.RichText = vgui.Create( "RichText", hnchat.derma.chatpanel )
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

		hnchat.derma.chat.message = vgui.Create( "DPanel", hnchat.derma.chatpanel )
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

	hnchat.derma.dms = hnchat.derma.dms or {}
		hnchat.derma.dms.tabs = vgui.Create( "DPropertySheet", hnchat.derma.dmpanel )
		hnchat.derma.dms.tabs:Dock(FILL)
		hnchat.derma.dms.tabs:SetFadeTime(0)
		hnchat.derma.dms.tabs:SetPadding(0)
		hnchat.derma.dms.tabs.Paint = function() end
		hnchat.derma.dms.tabs.CloseTab = function( self, tab, bRemovePanelToo )
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
		hnchat.derma.dms.tabs.tabs = {}

		hnchat.derma.dms.topbar = vgui.Create( "DPanel", hnchat.derma.dmpanel )
		hnchat.derma.dms.topbar:Dock(TOP)
		hnchat.derma.dms.topbar:DockPadding(1,1,1,1)

		hnchat.derma.dms.tabs.tabScroller:SetParent(hnchat.derma.dms.topbar)
		hnchat.derma.dms.tabs.tabScroller.Paint = function( self, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255) )
		end
		hnchat.derma.dms.tabs.tabScroller:Dock(FILL)
		hnchat.derma.dms.tabs.tabScroller:SetOverlap(-4)

		hnchat.derma.dms.newbutton = vgui.Create( "DButton", hnchat.derma.dms.topbar )
		hnchat.derma.dms.newbutton:SetSize(122,22)
		hnchat.derma.dms.newbutton:Dock(LEFT)
		hnchat.derma.dms.newbutton:SetText("New discussion with...")
		hnchat.derma.dms.newbutton.DoClick = function(self)
			local plys = player.GetAll()
			table.sort( plys, function(a,b) return a:UndecorateNick():Trim():lower() < b:UndecorateNick():Trim():lower() end)
			local menu = DermaMenu()
			for k, v in pairs(plys) do
				if not hnchat.derma.dms.tabs.tabs[v:SteamID()] then
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

		hnchat.derma.dms.TextEntry = vgui.Create( "DTextEntry", hnchat.derma.dmpanel )
		hnchat.derma.dms.TextEntry:Dock(BOTTOM)
		local w,h = hnchat.derma.dms.TextEntry:GetSize()
		hnchat.derma.dms.TextEntry:SetSize(w,14)
		hnchat.derma.dms.TextEntry.OldThink = hnchat.derma.dms.TextEntry.Think
		hnchat.derma.dms.TextEntry.Paint = function( self, w ,h )
			local col = self.HistoryPos == 0 and color_white or Color( 241, 201, 151, 255 )
			draw.RoundedBox( 0, 0, 0, w, h, col )
			self:DrawTextEntryText( Color( 0, 0, 0, 255 ), Color( 24, 131, 255, 255 ), Color( 0, 0, 0, 255 ))
			return false
		end
		hnchat.derma.dms.TextEntry.OnKeyCodeTyped = function( self, key )
			if key == KEY_ENTER then
				local str = self:GetValue():Trim()

				self:AddHistory(str)
				self:SetText("")
				--hnchat.closeChatbox()
				if str ~= "" and hnchat.derma.dms.tabs:GetActiveTab() ~= nil then
					hnchat.derma.dms.tabs:GetActiveTab():GetPanel().AddText( LocalPlayer(), color_white, ": ", str )
					dmPlayer( hnchat.derma.dms.tabs:GetActiveTab():GetPanel().Player, str )
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

	hnchat.derma.lua = hnchat.derma.lua or {}
		local modes = {
			Glua = "glua",
			Lua = "lua",
			Javscript = "javascript",
			Json = "json",
			Text = "text",
			["Plain text"] = "plain_text",
			Sql = "sql",
			Xml = "xml",
			Ada = "ada",
			["Assembly x86"] = "assembly_x86",
			Autohotkey = "autohotkey",
			Batchfile = "batchfile",
			C9search = "c9search",
			["C cpp"] = "c_cpp",
			Csharp = "csharp",
			Css = "css",
			Diff = "diff",
			Html = "html",
			["Html ruby"] = "html_ruby",
			Ini = "ini",
			Java = "java",
			Jsoniq = "jsoniq",
			Jsp = "jsp",
			Luapage = "luapage",
			Lucene = "lucene",
			Makefile = "makefile",
			Markdown = "markdown",
			Mysql = "mysql",
			Perl = "perl",
			Pgsql = "pgsql",
			Php = "php",
			Powershell = "powershell",
			Properties = "properties",
			Python = "python",
			Rhtml = "rhtml",
			Ruby = "ruby",
			Sh = "sh",
			Snippets = "snippets",
			Svg = "svg",
			Vbscript = "vbscript",
		}
		local themes = {
			Ambiance = "ambiance",
			Chaos = "chaos",
			Chrome = "chrome",
			Clouds = "clouds",
			["Clouds midnight"] = "clouds_midnight",
			Cobalt = "cobalt",
			["Crimson editor"] = "crimson_editor",
			Dawn = "dawn",
			Dreamweaver = "dreamweaver",
			Eclipse = "eclipse",
			Github = "github",
			["Idle fingers"] = "idle_fingers",
			Iplastic = "iplastic",
			Katzenmilch = "katzenmilch",
			["Kr theme"] = "kr_theme",
			Kuroir = "kuroir",
			Merbivore = "merbivore",
			["Merbivore soft"] = "merbivore_soft",
			["Mono industrial"] = "mono_industrial",
			Monokai = "monokai",
			["Pastel on dark"] = "pastel_on_dark",
			["Solarized dark"] = "solarized_dark",
			["Solarized light"] = "solarized_light",
			Sqlserver = "sqlserver",
			Terminal = "terminal",
			Textmate = "textmate",
			Tomorrow = "tomorrow",
			["Tomorrow night"] = "tomorrow_night",
			["Tomorrow night blue"] = "tomorrow_night_blue",
			["Tomorrow night bright"] = "tomorrow_night_bright",
			["Tomorrow night eighties"] = "tomorrow_night_eighties",
			Twilight = "twilight",
			["Vibrant ink"] = "vibrant_ink",
			Xcode = "xcode",
		}

		local ezdraw = function(self,w,h)
			col = self:IsHovered() and Color(222,222,222) or Color(234,234,234)
			textcol = self:IsHovered() and Color(96,42,180) or Color(81,81,81)
			textcol = self:IsDown() and color_white or textcol

			draw.RoundedBox( 0, 0, 0, w, h, col)
			draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			return true
		end

		hnchat.derma.lua.topbar = vgui.Create( "DHorizontalScroller", hnchat.derma.luapanel )
		hnchat.derma.lua.topbar:Dock(TOP)
		hnchat.derma.lua.topbar.Paint = function( self, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
		end
		hnchat.derma.lua.topbar:SetOverlap(0)

		hnchat.derma.lua.topbar.menu = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.menu:SetIcon("icon16/application_form_edit.png")
		hnchat.derma.lua.topbar.menu:SetText("Menu")
		hnchat.derma.lua.topbar.menu:Dock(LEFT)
		hnchat.derma.lua.topbar.menu.Paint = ezdraw
		hnchat.derma.lua.topbar.menu.DoClick = function(self)
			local menu = DermaMenu()
			menu:AddOption( "Configure", function()
				hnchat.derma.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "Toggle left panel", function()
				hnchat.derma.lua.leftbar:SetVisible(not hnchat.derma.lua.leftbar:IsVisible())
				hnchat.derma.lua.html:Dock(FILL) -- TODO: get that shit to auto do this
			end)
			menu:AddOption( "Show Help", function()
				hnchat.derma.lua.html:Call([[editor.showKeyboardShortcuts()]])
			end)

			local fix = menu:AddSubMenu("Fix")
				fix:AddOption( "Reopen URL", function()
					hnchat.derma.lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
				end)
				fix:AddOption( "Reload", function()
					hnchat.derma.lua.html:Refresh()
				end)
				fix:AddOption( "Reload (empty cache)", function()
					hnchat.derma.lua.html:Refresh(true)
				end)
			local mode = menu:AddSubMenu("Mode")
				for k, v in pairs(modes) do
					mode:AddOption(k, function()
						hnchat.derma.lua.html:Call([[editor.getSession().setMode("ace/mode/]]..v..[[");]])
					end)
				end
			local theme = menu:AddSubMenu("Theme")
				for k, v in SortedPairs(themes) do
					theme:AddOption(k, function()
						hnchat.derma.lua.html:Call([[editor.setTheme("ace/theme/]]..v..[[");]])
					end)
				end
			local fontsize = menu:AddSubMenu("Font Size")
				for i=9, 24 do
					fontsize:AddOption( i.." px", function()
						hnchat.derma.lua.html:Call("editor.setFontSize("..i..")")
					end)
				end

			menu:AddOption( "Legacy LuaDev", function()
				--hnchat.derma.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "Performance", function()
				--hnchat.derma.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "1 fps refresh", function()
				--hnchat.derma.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:Open()
		end
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.menu)

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.topbar)
			spacer:SetSize(32,24)
			spacer:Dock(LEFT)
			spacer.Paint = function(self) return false end
			hnchat.derma.lua.topbar:AddPanel(spacer)

		hnchat.derma.lua.topbar.run = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.run:SetIcon("icon16/cog_go.png")
		hnchat.derma.lua.topbar.run:SetText("Run")
		hnchat.derma.lua.topbar.run:SetSize(55,24)
		hnchat.derma.lua.topbar.run:Dock(LEFT)
		hnchat.derma.lua.topbar.run.Paint = function(self, w, h)
			col = self:IsHovered() and Color(222,222,222) or Color(190,243,188)
			textcol = self:IsHovered() and Color(96,42,180) or Color(81,81,81)
			textcol = self:IsDown() and color_white or textcol

			draw.RoundedBox( 0, 0, 0, w, h, col)
			draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			return true
		end
		hnchat.derma.lua.topbar.run.DoClick = function(self)
			--print(hnchat.derma.lua.html:Call([[editor.getValue()]]))
		end
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.run)

		hnchat.derma.lua.topbar.server = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.server:SetIcon("icon16/server.png")
		hnchat.derma.lua.topbar.server:SetText("Server")
		hnchat.derma.lua.topbar.server:SetSize(68,24)
		hnchat.derma.lua.topbar.server:Dock(LEFT)
		hnchat.derma.lua.topbar.server.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.server)

		hnchat.derma.lua.topbar.clients = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.clients:SetIcon("icon16/group.png")
		hnchat.derma.lua.topbar.clients:SetText("Clients")
		hnchat.derma.lua.topbar.clients:SetSize(68,24)
		hnchat.derma.lua.topbar.clients:Dock(LEFT)
		hnchat.derma.lua.topbar.clients.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.clients)

		hnchat.derma.lua.topbar.shared = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.shared:SetIcon("icon16/world.png")
		hnchat.derma.lua.topbar.shared:SetText("Shared")
		hnchat.derma.lua.topbar.shared:SetSize(70,24)
		hnchat.derma.lua.topbar.shared:Dock(LEFT)
		hnchat.derma.lua.topbar.shared.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.shared)
		
		local spacer = vgui.Create("DPanel", hnchat.derma.lua.topbar)
			spacer:SetSize(16,24)
			spacer:Dock(LEFT)
			spacer.Paint = function() return false end
			hnchat.derma.lua.topbar:AddPanel(spacer)

		hnchat.derma.lua.topbar.player = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.player:SetIcon("icon16/user.png")
		hnchat.derma.lua.topbar.player:SetText("Player")
		hnchat.derma.lua.topbar.player:SetSize(66,24)
		hnchat.derma.lua.topbar.player:Dock(LEFT)
		hnchat.derma.lua.topbar.player.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.player)

		hnchat.derma.lua.topbar.devs = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.devs:SetIcon("icon16/user_gray.png")
		hnchat.derma.lua.topbar.devs:SetSize(60,24)
		hnchat.derma.lua.topbar.devs:SetText("Devs")
		hnchat.derma.lua.topbar.devs:Dock(LEFT)
		hnchat.derma.lua.topbar.devs.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.devs)

		hnchat.derma.lua.topbar.near = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.near:SetIcon("icon16/group.png")
		hnchat.derma.lua.topbar.near:SetText("Nearby")
		hnchat.derma.lua.topbar.near:SetSize(71,24)
		hnchat.derma.lua.topbar.near:Dock(LEFT)
		hnchat.derma.lua.topbar.near.Paint = ezdraw
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.near)
		
		local spacer = vgui.Create("DPanel", hnchat.derma.lua.topbar)
			spacer:SetSize(16,24)
			spacer:Dock(LEFT)
			spacer.Paint = function() return false end
			hnchat.derma.lua.topbar:AddPanel(spacer)

		hnchat.derma.lua.topbar.servers = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.servers:SetIcon("icon16/server_lightning.png")
		hnchat.derma.lua.topbar.servers:SetText("Servers")
		hnchat.derma.lua.topbar.servers:Dock(LEFT)
		hnchat.derma.lua.topbar.servers:SetSize(85,24)
		hnchat.derma.lua.topbar.servers:SetEnabled(false)
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.servers)

		hnchat.derma.lua.topbar.javascript = vgui.Create( "DButton", hnchat.derma.lua.topbar )
		hnchat.derma.lua.topbar.javascript:SetIcon("icon16/script_gear.png")
		hnchat.derma.lua.topbar.javascript:SetText("Javascript")
		hnchat.derma.lua.topbar.javascript:Dock(LEFT)
		hnchat.derma.lua.topbar.javascript:SetSize(85,24)
		hnchat.derma.lua.topbar.javascript:SetEnabled(false)
		hnchat.derma.lua.topbar:AddPanel(hnchat.derma.lua.topbar.javascript)


		hnchat.derma.lua.leftbar = vgui.Create( "DScrollPanel", hnchat.derma.luapanel )
		hnchat.derma.lua.leftbar:Dock(LEFT)
		hnchat.derma.lua.leftbar.Paint = function( self, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
		end

		hnchat.derma.lua.leftbar.save = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.save:SetText("Save")
		hnchat.derma.lua.leftbar.save:SetIcon("icon16/script_save.png")
		hnchat.derma.lua.leftbar.save.Paint = ezdraw
		hnchat.derma.lua.leftbar.save:Dock(TOP)

		hnchat.derma.lua.leftbar.load = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.load:SetText("Load")
		hnchat.derma.lua.leftbar.load:SetIcon("icon16/script_edit.png")
		hnchat.derma.lua.leftbar.load.Paint = ezdraw
		hnchat.derma.lua.leftbar.load:Dock(TOP)

		hnchat.derma.lua.leftbar.open = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.open:SetText("Open")
		hnchat.derma.lua.leftbar.open:SetIcon("icon16/folder_explore.png")
		hnchat.derma.lua.leftbar.open.Paint = ezdraw
		hnchat.derma.lua.leftbar.open:Dock(TOP)

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.leftbar)
			spacer:SetSize(74,8)
			spacer:Dock(TOP)
			spacer.Paint = function() return false end

		hnchat.derma.lua.leftbar.loadurl = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.loadurl:SetText("Load URL")
		hnchat.derma.lua.leftbar.loadurl:SetIcon("icon16/page_link.png")
		hnchat.derma.lua.leftbar.loadurl.DoClick = function(self)
			Derma_StringRequest("Load URL","Paste in URL, pastebin and hastebin links are automatically in raw form.","",function(txt)
				if not txt:find("com/raw") then
					print("not raw")
				else
					print("fuckin raw")
				end
			end)
		end
		hnchat.derma.lua.leftbar.loadurl.Paint = ezdraw
		hnchat.derma.lua.leftbar.loadurl:Dock(TOP)

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.leftbar)
			spacer:SetSize(74,8)
			spacer:Dock(TOP)
			spacer.Paint = function() return false end

		hnchat.derma.lua.leftbar.pastebin = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.pastebin:SetText("pastebin")
		hnchat.derma.lua.leftbar.pastebin:SetIcon("icon16/page_link.png")
		hnchat.derma.lua.leftbar.pastebin.Paint = ezdraw
		hnchat.derma.lua.leftbar.pastebin:Dock(TOP)

		hnchat.derma.lua.leftbar.send = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.send:SetText("Send")
		hnchat.derma.lua.leftbar.send:SetIcon("icon16/email_go.png")
		hnchat.derma.lua.leftbar.send.Paint = ezdraw
		hnchat.derma.lua.leftbar.send:Dock(TOP)

		hnchat.derma.lua.leftbar.receive = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.receive:SetText("Receive")
		hnchat.derma.lua.leftbar.receive:SetIcon("icon16/email_open.png")
		hnchat.derma.lua.leftbar.receive.Paint = ezdraw
		hnchat.derma.lua.leftbar.receive:Dock(TOP)

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.leftbar)
			spacer:SetSize(74,8)
			spacer:Dock(TOP)
			spacer.Paint = function() return false end

		hnchat.derma.lua.leftbar.beauty = vgui.Create( "DButton", hnchat.derma.lua.leftbar )
		hnchat.derma.lua.leftbar.beauty:SetText("Beautify")
		hnchat.derma.lua.leftbar.beauty:SetIcon("icon16/font.png")
		hnchat.derma.lua.leftbar.beauty.Paint = ezdraw
		hnchat.derma.lua.leftbar.beauty:Dock(TOP)

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.leftbar)
			spacer:SetSize(74,8)
			spacer:Dock(TOP)
			spacer.Paint = function() return false end

		-- send as shit here

		local spacer = vgui.Create("DPanel", hnchat.derma.lua.leftbar)
			spacer:SetSize(74,8)
			spacer:Dock(TOP)
			spacer.Paint = function() return false end

		-- easy lua combo box here

		hnchat.derma.lua.prop = vgui.Create( "DPropertySheet", hnchat.derma.luapanel )
		hnchat.derma.lua.prop:Dock(FILL)
		hnchat.derma.lua.prop.Paint = function() return false end

		-- propertysheet (done)
		-- drag base (might be built into property sheet's tabs)
		-- then tabs

		--[[hnchat.derma.lua.html = vgui.Create( "DHTML", hnchat.derma.luapanel )
		hnchat.derma.lua.html:Dock(FILL)
		hnchat.derma.lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
		hnchat.derma.lua.html:SetAllowLua(true)]]

		--[[
			[LEDITOR] InternalSnippetsUpdate -> function () { [native code] }
			[LEDITOR] OnCode -> function () { [native code] }
			[LEDITOR] OnLog -> function () { [native code] }
			[LEDITOR] OnReady -> function () { [native code] }
			[LEDITOR] OnSelection -> function () { [native code] }
			[LEDITOR] oncontextmenu -> function () { [native code] }
			[LEDITOR] onmousedown -> function () { [native code] }

			 function PANEL:GetCode( sessionName )
			 	return self:GetHasLoaded() and self:GetSession( sessionName ) or ""
			 end
		]]

	hnchat.derma.config = hnchat.derma.config or {}
		hnchat.derma.config.CList = vgui.Create( "DCategoryList", hnchat.derma.configpanel )
		hnchat.derma.config.CList:Dock(FILL)

		hnchat.derma.config.chat = hnchat.derma.config.CList:Add("Chat")
			hnchat.derma.config.chat:SetExpanded(false)
			hnchat.derma.config.chat:SetPadding(0)

			hnchat.derma.config.chat.list = vgui.Create( "DPanelList", hnchat.derma.config.chat )
			hnchat.derma.config.chat.list:SetSpacing(7)
			hnchat.derma.config.chat.list:SetPadding(5)
			hnchat.derma.config.chat.list:EnableHorizontal(false)
			hnchat.derma.config.chat.list:EnableVerticalScrollbar(true)
			hnchat.derma.config.chat:SetContents(hnchat.derma.config.chat.list)

			for k, v in pairs(hnchat.settings.chat) do
				hnchat.derma.config.chat.k = vgui.Create("DCheckBoxLabel")
				hnchat.derma.config.chat.k:SetText(v.label)
				hnchat.derma.config.chat.k:SetConVar(v.convar:GetName())
				hnchat.derma.config.chat.k:SetValue(v.convar:GetBool())
				hnchat.derma.config.chat.k:SizeToContents()
				hnchat.derma.config.chat.k:SetTextColor(Color( 3, 3, 3, 255 ))
				hnchat.derma.config.chat.k:SetToolTip(v.desc)
				hnchat.derma.config.chat.list:AddItem(hnchat.derma.config.chat.k)
			end
		hnchat.derma.config.chathud = hnchat.derma.config.CList:Add("Chat HUD")
			hnchat.derma.config.chathud:SetExpanded(false)
			hnchat.derma.config.chathud:SetPadding(0)
		hnchat.derma.config.audio = hnchat.derma.config.CList:Add("Audio")
			hnchat.derma.config.audio:SetExpanded(false)
			hnchat.derma.config.audio:SetPadding(0)

			hnchat.derma.config.audio.list = vgui.Create( "DPanelList", hnchat.derma.config.audio )
			hnchat.derma.config.audio.list:SetSpacing(7)
			hnchat.derma.config.audio.list:SetPadding(5)
			hnchat.derma.config.audio.list:EnableHorizontal(false)
			hnchat.derma.config.audio.list:EnableVerticalScrollbar(true)
			hnchat.derma.config.audio:SetContents(hnchat.derma.config.audio.list)

			hnchat.derma.config.audio.outmute = vgui.Create("DCheckBoxLabel")
			hnchat.derma.config.audio.outmute:SetText("Out of game mute")
			hnchat.derma.config.audio.outmute:SetConVar("snd_mute_losefocus")
			hnchat.derma.config.audio.outmute:SetValue(GetConVar("snd_mute_losefocus"):GetBool())
			hnchat.derma.config.audio.outmute:SizeToContents()
			hnchat.derma.config.audio.outmute:SetTextColor(Color( 3, 3, 3, 255 ))
			hnchat.derma.config.audio.outmute:SetToolTip("Mute in game sounds while tabbed out of game")
			hnchat.derma.config.audio.list:AddItem(hnchat.derma.config.audio.outmute)
		hnchat.derma.config.graphics = hnchat.derma.config.CList:Add("Performance / Graphics")
			hnchat.derma.config.graphics:SetExpanded(false)
			hnchat.derma.config.graphics:SetPadding(0)
		hnchat.derma.config.dms = hnchat.derma.config.CList:Add( "PM" )
			hnchat.derma.config.dms:SetExpanded(false)
			hnchat.derma.config.dms:SetPadding(0)
		hnchat.derma.config.game = hnchat.derma.config.CList:Add("Game")
			hnchat.derma.config.game:SetExpanded(false)
			hnchat.derma.config.game:SetPadding(0)

			hnchat.derma.config.game.list = vgui.Create( "DPanelList", hnchat.derma.config.game )
			hnchat.derma.config.game.list:SetSpacing(7)
			hnchat.derma.config.game.list:SetPadding(5)
			hnchat.derma.config.game.list:EnableHorizontal(false)
			hnchat.derma.config.game.list:EnableVerticalScrollbar(true)
			hnchat.derma.config.game:SetContents(hnchat.derma.config.game.list)

			hnchat.derma.config.game.netgraph = {}
			for i=1, 4 do
				hnchat.derma.config.game.netgraph[i] = vgui.Create("DCheckBoxLabel")
				hnchat.derma.config.game.netgraph[i]:SetText( "Net Graph " .. i )
				hnchat.derma.config.game.netgraph[i].val = i
				hnchat.derma.config.game.netgraph[i]:SetValue(0)
				hnchat.derma.config.game.netgraph[i]:SizeToContents()
				hnchat.derma.config.game.netgraph[i]:SetTextColor(Color( 3, 3, 3, 255 ))
				hnchat.derma.config.game.netgraph[i]:SetToolTip( "Set net graph value to " .. i )
				hnchat.derma.config.game.list:AddItem(hnchat.derma.config.game.netgraph[i])
			end
			local highval = 0
			for k, v in pairs(hnchat.derma.config.game.netgraph) do
				v.OnChange = function( self, val )
					if val then
						LocalPlayer():ConCommand( "net_graph " .. tostring(self.val) )
						for k, v in pairs(hnchat.derma.config.game.netgraph) do
							if v ~= self then
								v:SetValue(0)
							else
								--nothing
							end
						end
					end
				end
			end
		hnchat.derma.config.media = hnchat.derma.config.CList:Add( "Media Player" )
			hnchat.derma.config.media:SetExpanded(false)
			hnchat.derma.config.media:SetPadding(0)
 
	hnchat.derma.tabs:AddSheet( "Global", hnchat.derma.chatpanel, "icon16/comments.png", false, false, "Chat" )
	hnchat.derma.tabs:AddSheet( "PM", hnchat.derma.dmpanel, "icon16/group.png", false, false, "PM" )
	local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer.Tab.Paint = function(self) return false end
		spacer.Tab:SetEnabled(false)
		spacer.Tab:SetCursor("arrow")
		local spacer2 = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer2.Tab.Paint = function(self) return false end
		spacer2.Tab:SetEnabled(false)
		spacer2.Tab:SetCursor("arrow")
	hnchat.derma.tabs:AddSheet( "Lua", hnchat.derma.luapanel, "icon16/page_edit.png", false, false, "Lua" )
	hnchat.derma.tabs:AddSheet( "Settings", hnchat.derma.configpanel, "icon16/wrench_orange.png", false, false, "Config" )

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


	oldPos = oldPos or chat.GetChatBoxPos
	function chat.GetChatBoxPos()
		return hnchat.derma.Frame:GetPos()
	end
	oldSize = oldSize or chat.GetChatBoxSize
	function chat.GetChatBoxSize()
		return hnchat.derma.Frame:GetSize()
	end
	oldOpen = oldOpen or chat.Open
	function chat.Open(mode)
		hnchat.openChatbox("Global")
		hnchat.derma.chat.TextEntry:RequestFocus()
	end
	oldClose = oldClose or chat.Close
	function chat.Close()
		hnchat.closeChatbox()
	end

	oldChatAddText = oldChatAddText or chat.AddText
	function chat.AddText(...)
		oldChatAddText(...)
		hnchat.derma.chat.RichText:AppendText("\n")

		if hnchat.settings.chat.time_stamps.convar:GetBool() then
			hnchat.derma.chat.RichText:InsertColorChange( 119, 171, 218, 255 )
			hnchat.derma.chat.RichText:AppendText( hnchat.settings.chat.time_24h.convar:GetBool() and (os.date("%H:%M", os.time())) or (os.date("%I:%M %p", os.time())) )

			hnchat.derma.chat.RichText:InsertColorChange( 255, 255, 255, 255 )
			hnchat.derma.chat.RichText:AppendText(" - ")
		end

		for _, obj in pairs({...}) do
			if type(obj) == "table" then
				hnchat.derma.chat.RichText:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			elseif type(obj) == "string"  then
				--[[if (obj:find(LocalPlayer():Nick()) or obj:find(LocalPlayer():UndecorateNick())) and hnchat.config.chat.highlight.convar:GetBool() then
					hnchat.derma.chat.RichText:InsertColorChange( 255, 90, 35, 255 )
				end]]

				--[[if obj:sub(3, 3):find(">") and hnchat.config.chat.greentext.convar:GetBool() then
					hnchat.derma.chat.RichText:InsertColorChange( 46, 231, 46, 255)
				end]]

				local url = obj:match("https?://[^%s%\"]+")
				local s,e = obj:find("https?://[^%s%\"]+")

				if url then hnchat.derma.chat.RichText:InsertClickableTextStart(url) end
				hnchat.derma.chat.RichText:AppendText(obj)
				hnchat.derma.chat.RichText:InsertClickableTextEnd()
			elseif obj:IsPlayer() then
				--local mark = markup.Parse(obj:Nick())
				--if (markup.blocks[1].colour.a == 255 and markup.blocks[1].colour.b == 255 and mark.blocks[1].colour.g == 255 and mark.blocks[1].colour.r == 255) then
					local col = GAMEMODE:GetTeamColor(obj)
				--[[else
					local col = markup.blocks[1].colour
				end]]

				hnchat.derma.chat.RichText:InsertColorChange( col.r, col.g, col.b, 255 )
				hnchat.derma.chat.RichText:AppendText( obj:UndecorateNick() )
			end
		end
	end

	net.Receive("hnchat_local_receive", function(len)
		local ply = net.ReadEntity()
		local txt = net.ReadString()

		chat.AddText( Color(24,161,35), "(Local) ", ply, color_white, ": " .. txt )
	end)

	net.Receive("hnchat_dm_receive", function(len)
		local ply = net.ReadEntity()
		local txt = net.ReadString()

		if not hnchat.derma.dms.tabs.tabs[ply:SteamID()] then hnchat.addDM(ply) end

		hnchat.derma.dms.tabs.tabs[ply:SteamID()].AddText( ply, color_white, ": " .. txt )
		--if not hnchat.derma.dms.tabs:GetActiveTab():GetPanel():IsVisible() then
			hnchat.derma.dms.tabs.tabs[ply:SteamID()].unread = true
			surface.PlaySound("friends/message.wav")
			chat.AddText("New DM from", ply)
		--end

		if system.IsWindows() and not system.HasFocus() then system.FlashWindow() end
	end)

	hook.Add( "PlayerBindPress", "hnchat", function( ply, bind, pressed )
		if bind:find("messagemode2") then
			RunConsoleCommand("hnchat_open_lua")
			return true
		elseif bind:find("messagemode") then
			RunConsoleCommand("hnchat_open")
			return true
		end
	end )
	hook.Add( "ChatText", "serverNotifications", function( index, name, text, type )
		if type == "servermsg" or type == "none" then
			chat.AddText( Color(151,211,255), text )
		else
			print(index, name, text, type)
		end
	end )
	concommand.Add( "hnchat_open",function() -- opens chat
		hnchat.openChatbox("Global")
		hnchat.derma.chat.TextEntry:RequestFocus()
	end)
	concommand.Add( "hnchat_open_config", function() -- opens config panel
		hnchat.openChatbox("Settings")
	end)
	concommand.Add( "hnchat_open_local",function() -- opens chat in local
		RunConsoleCommand("hnchat_open")
		hnchat.derma.chat.msgmode.curtype = 2
	end)
	concommand.Add( "hnchat_open_lua",function() -- opens lua panel
		hnchat.openChatbox("Lua")
		--hnchat.derma.lua.html:RequestFocus()
	end)
	concommand.Add( "hnchat_open_mode",function()
		-- idk what this does lol
	end)
	concommand.Add( "hnchat_open_pm",function() 
		hnchat.openChatbox("PM")
		hnchat.derma.dms.TextEntry:RequestFocus()
	end)
	concommand.Add( "hnchat_open_team",function() -- open chat in team
		RunConsoleCommand("hnchat_open")
		hnchat.derma.chat.msgmode.curtype = 1
	end)

	function hnchat.UnLoad()
		-- restore original functions
		chat.AddText = oldChatAddText
		chat.GetChatBoxPos = oldPos
		chat.GetChatBoxSize = oldSize
		chat.Open = oldOpen
		chat.Close = oldClose
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

		hnchat = nil
	end

	hnchat.closeChatbox()
end)
