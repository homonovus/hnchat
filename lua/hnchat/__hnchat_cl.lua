-- TODO: finish DMs, finish adding in editor stuff
-- finish adding in settings options
-- finish adding in links
-- make modular?? : easier with dpropertysheet
-- remove weebshit from integration
-- remake main derma with dpropertysheet
-- figure out how to get value of editor from lua: maybe window.gmodinterface???
-- give editor proper tab support with dpropertysheet 

-- remove these after finished; chat will only be loaded once

hook.Add( "Initialize", "hnchat", function()

	local PLAYER = FindMetaTable( "Player" )
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
	function Say(txt)
		LocalPlayer():ConCommand( "say" .. (team == true and "_team" or "") .. " " .. txt )
	end
	function SayLocal( txt )
		local meme = { Color(255,0,0), "(Local @ " }
		local sphere = ents.FindInSphere( LocalPlayer():GetPos(), 196 )

		if util.NetworkStringToID( "hnchat_local_fromplayer" ) ~= 0 then
			net.Start( "hnchat_local_fromplayer", false )
				local plys = {}
				for k, v in pairs( sphere ) do
					if v:IsPlayer() and v ~= LocalPlayer() then
						table.insert( plys, v )
					end
				end
				net.WriteTable( plys )
				net.WriteString( txt )
			net.SendToServer()

			for k, v in pairs(plys) do
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
			chat.AddText( Color(24,161,35), "(Local) ", LocalPlayer(), Color(255,255,255), ": " .. txt )
		else
			chat.AddText( Color(192,192,192), "[", Color(176,11,30), "HNCHAT", Color(192,192,192), "] ", Color(255,255,255), "Chat was installed incorrectly; or, you only have the client side portion. For proper functionality, install the serverside files." )
		end
	end
	local function GetTime( hrtype )
		if hrtype then
			return os.date( "%H:%M", os.time()) -- 24 hour
		else
			return os.date( "%I:%M %p", os.time()) -- 12 hour
		end	
	end
	function draw.OutlinedBox( x, y, w, h, thickness, clr )
		surface.SetDrawColor( clr )
		for i=0, thickness - 1 do
			surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
		end
	end

	--[[

		chat icons
			emoticon_grin
			emoticon_smile
			color_swatch

		setting icons
			comment
			comments
			audio symbol
			monitor
			group
			joystick
			media player
	]]

	hnchat = hnchat or {}

	oldChatAddText = oldChatAddText or chat.AddText
	function chat.AddText( ... )
		hnchat.globalchat.RichText:AppendText( "\n" )

		if hnchat.config.chat.time_stamps.convar:GetBool() then
			hnchat.globalchat.RichText:InsertColorChange( 119, 171, 218, 255 )
			hnchat.globalchat.RichText:AppendText( GetTime( hnchat.config.chat.time_24h.convar:GetBool() ) )

			hnchat.globalchat.RichText:InsertColorChange( 255, 255, 255, 255 )
			hnchat.globalchat.RichText:AppendText(" - ")
		end

		for _, obj in pairs( {...} ) do
			if type(obj) == "table" then
				hnchat.globalchat.RichText:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			elseif type(obj) == "string"  then
				if (obj:find(LocalPlayer():Nick()) or obj:find(LocalPlayer():UndecorateNick())) and hnchat.config.chat.highlight.convar:GetBool() then
					hnchat.globalchat.RichText:InsertColorChange( 255, 90, 35, 255 )
				end

				if obj:sub(3, 3):find(">") and hnchat.config.chat.greentext.convar:GetBool() then
					hnchat.globalchat.RichText:InsertColorChange( 46, 231, 46, 255)
				end

				if obj:find("https?://[^%s%\"]+") then
					local url = obj:match( "https?://[^%s%\"]+" )
					local s, e = obj:find( url )

					local txt = 

					hnchat.globalchat.RichText:InsertClickableTextStart( "ClickLink" )
					hnchat.globalchat.RichText:AppendText( obj )
					hnchat.globalchat.RichText:AppendText( " !!!!!!!!!!!!!!linked" )
				else
					hnchat.globalchat.RichText:AppendText( obj )
				end

				hnchat.globalchat.RichText:InsertClickableTextEnd()
			elseif obj:IsPlayer() then
				local mark = markup.Parse( obj:Nick() )
				local col = (mark.blocks[1].colour.a == 255 and mark.blocks[1].colour.b == 255 and mark.blocks[1].colour.g == 255 and mark.blocks[1].colour.r == 255 ) and GAMEMODE:GetTeamColor( obj ) or mark.blocks[1].colour

				hnchat.globalchat.RichText:InsertColorChange( col.r, col.g, col.b, 255 )
				hnchat.globalchat.RichText:AppendText( obj:UndecorateNick() )
			end
		end

		--eChat.chatLog:SetVisible( true )
		--eChat.lastMessage = CurTime()

		oldChatAddText( ... )
	end

	hnchat.config = {
		["chat"] = {
			["time_stamps"]	= {
				["label"]	= "Timestamps (chat history)",
				["convar"]	= CreateClientConVar( "hnchat_timestamps", 1 ),
				["desc"]	= "Display timestamps in chatbox",
			},
			["time_24h"]	= {
				["label"]	= "24 Hour Timestamps",
				["convar"]	= CreateClientConVar( "hnchat_timestamps_24hr", 1 ),
				["desc"]	= "Display 24 hour time in timestamps",
			},
			["greentext"]	= {
				["label"]	= "> Green text",
				["convar"]	= CreateClientConVar( "hnchat_greentext", 1 ),
				["desc"]	= "> implying you dont know what greentext is",
			},
			["highlight"]	= {
				["label"]	= "Highlight messages that mention you",
				["convar"]	= CreateClientConVar( "hnchat_highlight", 1 ),
				["desc"]	= "Messages will be coloured orange",
			},
		},
		["pos"] = {
			["preposx"]		= 0,
			["preposy"]		= 0,
			["presizex"] 	= 0,
			["presizey"] 	= 0,
			["posx"]		= 0,
			["posy"]		= 0,
			["sizex"]		= 0,
			["sizey"]		= 0,
		},
		["debug"] = true,
	}

	function hnchat.changetab( totab )
		for k, v in pairs(hnchat.globalchat) do
			if k ~= "tab" then
				v:SetVisible(false)
			else
				v.IsActive = false
			end
		end
		for k, v in pairs(hnchat.dms) do
			if k ~= "tab" then
				v:SetVisible(false)
			else
				v.IsActive = false
			end
		end
		for k, v in pairs(hnchat.lua) do
			if k ~= "tab" then
				v:SetVisible(false)
			else
				v.IsActive = false
			end
		end
		for k, v in pairs(hnchat.settings) do
			if k ~= "tab" then
				v:SetVisible(false)
			else
				v.IsActive = false
			end
		end

		for k, v in pairs(totab) do
			if k ~= "tab" then
				v:SetVisible(true)
			else
				v.IsActive = true
			end
		end

		if totab == hnchat.globalchat or totab == hnchat.dms then
			totab.TextEntry:RequestFocus()
		elseif totab == hnchat.lua then
			totab.html:RequestFocus()
		end
	end
	function hnchat.tofull()
		hnchat.config.pos.preposx, hnchat.config.pos.preposy = hnchat.dFrame:GetPos()
		hnchat.config.pos.presizex, hnchat.config.pos.presizey = hnchat.dFrame:GetSize()
		hnchat.isFull = true

		hnchat.dFrame:SetSize( ScrW(), ScrH())
		hnchat.dFrame:SetPos( 0, 0 )
		hnchat.dFrame:SetDraggable( false )

		hnchat.CloseButton:SetPos( ScrW() - 46, 0 )

		hnchat.FSButton:SetPos( ScrW() - 70, 0 )
		hnchat.FSButton.DoClick = hnchat.towin
	end
	function hnchat.towin()
		hnchat.isFull = false

		hnchat.dFrame:SetSize( 844, 496 )
		hnchat.dFrame:SetDraggable( true )
		hnchat.dFrame:SetPos( hnchat.config.pos.preposx, hnchat.config.pos.preposy )
		hnchat.dFrame:SetSize( hnchat.config.pos.presizex, hnchat.config.pos.presizey )

		hnchat.CloseButton:SetPos( hnchat.config.pos.sizex - 46, 0 )	

		hnchat.FSButton:SetPos( hnchat.config.pos.sizex - 70, 0 )
		hnchat.FSButton.DoClick = hnchat.tofull
	end
	function hnchat.openChatbox( mode )
		hnchat.dFrame:MakePopup()
		hnchat.dFrame:SetVisible( true )

		if mode == "global" then
			hnchat.changetab( hnchat.globalchat )
			hnchat.globalchat.msgmode.curtype = 0
			gamemode.Call( "StartChat" )
		elseif mode == "lua" then
			hnchat.changetab( hnchat.lua )
		else
			hnchat.dFrame:MakePopup()
		end
		gamemode.Call( "ChatTextChanged", "" )
	end
	function hnchat.closeChatbox()
		hnchat.dFrame:SetMouseInputEnabled( false )
		hnchat.dFrame:SetKeyboardInputEnabled( false )
		gui.EnableScreenClicker( false )
		hnchat.dFrame:SetVisible( false )

		gamemode.Call( "FinishChat" )

		hnchat.globalchat.TextEntry:SetText( "" )
		hnchat.dms.TextEntry:SetText( "" )
		gamemode.Call( "ChatTextChanged", "" )
	end

	hnchat.dFrame = vgui.Create( "DFrame" )
	hnchat.dFrame:Center()
	hnchat.dFrame:SetSize( 844, 496 )
	hnchat.dFrame:SetTitle("")
	hnchat.dFrame:SetDraggable(true)
	hnchat.dFrame:SetSizable(true)
	hnchat.dFrame:ShowCloseButton(false)
	hnchat.dFrame:MakePopup()
	hnchat.dFrame:SetScreenLock(true)
	hnchat.dFrame:SetMinimumSize( 200, 100 )
	hnchat.dFrame.Paint = function( self, w, h )
		hnchat.config.pos.posx, hnchat.config.pos.posy = hnchat.dFrame:GetPos()
		hnchat.config.pos.sizex, hnchat.config.pos.sizey = hnchat.dFrame:GetSize()

		draw.OutlinedBox( 0, 0, w, h, 1, Color( 64, 64, 64, 128) )
		surface.DrawRect( 0, 0, w, h )
		return false
	end
	hnchat.dFrame.OnKeyCodePressed = function( self, key )
		if key == KEY_F11 then hnchat.FSButton:DoClick() end
	end
	hnchat.dFrame.oldThink = hnchat.dFrame.Think
	hnchat.dFrame.Think = function(self)
		if input.IsKeyDown(KEY_ESCAPE) then
			gui.HideGameUI()
			hnchat.closeChatbox()
		end
		self.oldThink(self)
	end
	chatgui = hnchat.dFrame -- support for chatsounds
		
	hnchat.CloseButton = vgui.Create( "DButton", hnchat.dFrame )
	hnchat.CloseButton:SetText( "" )
	hnchat.CloseButton:SetPos( hnchat.config.pos.sizex - 46, 0 )
	hnchat.CloseButton:SetSize( 42, 16 )
	hnchat.CloseButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(255,0,0) or Color(255,62,62)

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, false, true )
		draw.SimpleTextOutlined("r", "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		return true
	end
	function hnchat.CloseButton:DoClick()
		hnchat.closeChatbox()
	end
	hnchat.CloseButton.Think = function(self)
		self:SetPos( hnchat.config.pos.sizex - 46, 0 )
	end

	hnchat.FSButton = vgui.Create( "DButton", hnchat.dFrame )
	hnchat.FSButton:SetText("")
	hnchat.FSButton:SetPos( hnchat.config.pos.sizex - 70, 0 )
	hnchat.FSButton:SetSize( 24, 16 )
	hnchat.FSButton.defcol = Color(177,177,177)
	hnchat.FSButton.hovcol = Color(128,128,128)
	hnchat.FSButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(128,128,128) or Color(177,177,177)
		local symbol = hnchat.isFull and "2" or "1"

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, true, false )
		draw.SimpleTextOutlined(symbol, "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		return true
	end
	hnchat.FSButton.Think = function(self)
		self:SetPos( hnchat.config.pos.sizex - 70, 0 )
	end
	hnchat.FSButton.DoClick = hnchat.tofull

	hnchat.globalchat = {}
		hnchat.globalchat.tab = vgui.Create( "DButton", hnchat.dFrame )
		hnchat.globalchat.tab.isActive = false
		hnchat.globalchat.tab:SetText("Global")
		hnchat.globalchat.tab:SetPos(9,6)
		hnchat.globalchat.tab:SetSize( 63, 19 )
		hnchat.globalchat.tab.DoClick = function( self )
			hnchat.changetab( hnchat.globalchat )
		end
		hnchat.globalchat.tab.Paint = function( self, w, h )
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(255,255,255,200), self.isActive, self.isActive, false, false )
		end

		hnchat.globalchat.RichText = vgui.Create( "RichText", hnchat.dFrame )
		hnchat.globalchat.RichText:SetPos( hnchat.config.pos.posx + 5, hnchat.config.pos.posy + 25 )
		hnchat.globalchat.RichText:SetSize( hnchat.config.pos.sizex - 10, hnchat.config.pos.sizey - 10 )
		hnchat.globalchat.RichText.Paint = function( self, w ,h ) draw.RoundedBox( 0, 0, 0, w, h, Color( 37, 37, 37, 240 ) ) end
		hnchat.globalchat.RichText.Think = function( self )
			self:SetSize( hnchat.config.pos.sizex - 10, hnchat.config.pos.sizey - 41 )
		end
		hnchat.globalchat.RichText.PerformLayout = function( self )
			self:SetFontInternal( "DermaDefault" )
			self:SetFGColor( Color( 255, 255, 255 ) )
		end
		hnchat.globalchat.RichText.ActionSignal = function( self, signalName, signalValue )
			if ( signalName == "TextClicked" ) then
				if ( signalValue == "OpenWiki" ) then
					--gui.OpenURL( "http://wiki.garrysmod.com/page/Category:RichText" )
					print('clciked link')
				end
			end
		end

		hnchat.globalchat.msgmode = vgui.Create("DButton", hnchat.dFrame )
		hnchat.globalchat.msgmode:SetPos( 5, hnchat.config.pos.sizey - 16 )
		hnchat.globalchat.msgmode.curtype = 0
		hnchat.globalchat.msgmode.types = {
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
		hnchat.globalchat.msgmode.Think = function( self )
			local assx, assy = hnchat.dFrame:GetSize()
			self:SetPos( 5, assy - 16 )
			self:SetText( self.types[self.curtype].name )
			self:SetSize( self.types[self.curtype].size.x, self.types[self.curtype].size.y)
		end
		hnchat.globalchat.msgmode.DoClick = function( self )
			self.curtype = self.curtype < 5 and self.curtype + 1 or 0
			self:SetText( self.types[self.curtype].name )
			self:SetSize( self.types[self.curtype].size.x, self.types[self.curtype].size.y)
		end
		hnchat.globalchat.msgmode.DoRightClick = function( self )
			local menu = DermaMenu()
			for i = 0, #hnchat.globalchat.msgmode.types do
				menu:AddOption( hnchat.globalchat.msgmode.types[i].name, function()
					hnchat.globalchat.msgmode.curtype = i
				end ):SetIcon( hnchat.globalchat.msgmode.types[i].icon .. ".png")
			end
			menu:Open()
		end

		hnchat.globalchat.TextEntry = vgui.Create( "DTextEntry", hnchat.dFrame )
		hnchat.globalchat.TextEntry:SetPos( 37, hnchat.config.pos.sizey + 15 )
		hnchat.globalchat.TextEntry:SetSize( ( hnchat.config.pos.sizex - 114 ) - hnchat.globalchat.msgmode.types[hnchat.globalchat.msgmode.curtype].size.x + 30 , 16 )
		hnchat.globalchat.TextEntry.Think = function( self )
			local assx, assy = hnchat.dFrame:GetSize()
			self:SetPos( hnchat.globalchat.msgmode.types[hnchat.globalchat.msgmode.curtype].size.x + 6, assy - 15 )
			self:SetSize( (assx - 114 ) - hnchat.globalchat.msgmode.types[hnchat.globalchat.msgmode.curtype].size.x + 30, 14 )
			gamemode.Call( "ChatTextChanged", self:GetValue() )
		end
		hnchat.globalchat.TextEntry.Paint = function( self, w ,h )
			local col = self.HistoryPos == 0 and Color( 255, 255, 255, 255 ) or Color( 241, 201, 151, 255 )
			draw.RoundedBox( 0, 0, 0, w, h, col )
			self:DrawTextEntryText( Color( 0, 0, 0, 255 ), Color( 24, 131, 255, 255 ), Color( 0, 0, 0, 255 ))
			return false
		end
		hnchat.globalchat.TextEntry.OnKeyCodeTyped = function( self, key )
			if key == KEY_ENTER then
				local str = self:GetValue()

				self:AddHistory(str)
				self:SetText("")
				if str ~= "" then
					if hnchat.globalchat.msgmode.curtype == 0 then
						Say( str, false )
					elseif hnchat.globalchat.msgmode.curtype == 1 then
						Say( str, true )
					elseif hnchat.globalchat.msgmode.curtype == 2 then
						SayLocal( str )
					elseif hnchat.globalchat.msgmode.curtype == 3 then
						RunConsoleCommand( "saysound", str)
					elseif hnchat.globalchat.msgmode.curtype == 4 then
						LocalPlayer():ConCommand( str )
					elseif hnchat.globalchat.msgmode.curtype == 6 then
						Say( string.anime(str), false )
					else
						Say( str, false )
					end
				end

				self.HistoryPos = 0
				hnchat.closeChatbox()
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
						hnchat.globalchat.msgmode.curtype = hnchat.globalchat.msgmode.curtype > 0 and hnchat.globalchat.msgmode.curtype - 1 or #hnchat.globalchat.msgmode.types
					else
						hnchat.globalchat.msgmode.curtype = hnchat.globalchat.msgmode.curtype < #hnchat.globalchat.msgmode.types and hnchat.globalchat.msgmode.curtype + 1 or 0
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

	hnchat.dms = {}
		hnchat.dms.tab = vgui.Create( "DButton", hnchat.dFrame )
		hnchat.dms.tab.isActive = false
		hnchat.dms.tab:SetText("PM")
		hnchat.dms.tab:SetPos(69,6)
		hnchat.dms.tab:SetSize( 48, 19 )
		hnchat.dms.tab.DoClick = function( self )
			hnchat.changetab( hnchat.dms )
		end
		hnchat.dms.tab.Paint = function( self, w, h )
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(255,255,255,200), self.isActive, self.isActive, false, false )
		end

		hnchat.dms.TextEntry = vgui.Create("DTextEntry", hnchat.dFrame)
		hnchat.dms.TextEntry:SetPos( 5, hnchat.config.pos.sizey + 15 )
		hnchat.dms.TextEntry:SetSize(  hnchat.config.pos.sizex - 10, 14 )
		hnchat.dms.TextEntry.Think = function( self )
			local assx, assy = hnchat.dFrame:GetSize()
			self:SetPos( 5, assy - 15 )
			self:SetSize( assx - 10, 14 )
		end
		hnchat.dms.TextEntry.Paint = function( self, w ,h )
			draw.RoundedBoxEx( 2, 0, 0, w, h, Color( 255, 255, 255, 255 ), true, true, true, true )
			self:DrawTextEntryText( Color( 0, 0, 0, 255 ), Color( 24, 131, 255, 255 ), Color( 0, 0, 0, 255 ))
			return false
		end
		hnchat.dms.TextEntry.OnKeyCodeTyped = function( self, key )
			if key == KEY_ENTER then
				local str = self:GetValue()
				if str == "" then return end

				self:AddHistory(str)
				self:SetText("")

				self.HistoryPos = 0
			elseif key == KEY_UP then
				self.HistoryPos = self.HistoryPos - 1
				self:UpdateFromHistory()
			elseif key == KEY_DOWN then
				self.HistoryPos = self.HistoryPos + 1
				self:UpdateFromHistory()
			end
		end

	hnchat.lua = {}
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
		hnchat.lua.tab = vgui.Create( "DButton", hnchat.dFrame )
			hnchat.lua.tab.isActive = false
			hnchat.lua.tab:SetText("Lua")
			hnchat.lua.tab:SetPos(141,6)
			hnchat.lua.tab:SetSize( 51, 19 )
			hnchat.lua.tab.DoClick = function( self )
				hnchat.changetab( hnchat.lua )
			end
			hnchat.lua.tab.Paint = function( self, w, h )
				draw.RoundedBoxEx( 4, 0, 0, w, h, Color(255,255,255,200), self.isActive, self.isActive, false, false )
				return false
			end

		hnchat.lua.paddingone = vgui.Create( "DHorizontalScroller", hnchat.dFrame )
			hnchat.lua.paddingone:Dock( TOP )
			hnchat.lua.paddingone.Paint = function( self, w, h )
				draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
			end
			hnchat.lua.paddingone:SetOverlap(0)
		hnchat.lua.paddingone.menu = vgui.Create( "DButton", hnchat.lua.paddingone )
		hnchat.lua.paddingone.menu:SetIcon("icon16/application_form_edit.png")
		hnchat.lua.paddingone.menu:SetText("Menu")
		hnchat.lua.paddingone.menu:Dock(LEFT)
		hnchat.lua.paddingone.menu.DoClick = function(self)
			local menu = DermaMenu()
			menu:AddOption( "Configure", function()
				hnchat.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "Toggle left panel", function()
				hnchat.lua.paddingtwo:SetVisible(not hnchat.lua.paddingtwo:IsVisible())
				hnchat.lua.html:Dock(FILL) -- TODO: get that shit to auto do this
			end)
			menu:AddOption( "Show Help", function()
				hnchat.lua.html:Call([[editor.showKeyboardShortcuts()]])
			end)

			local fix = menu:AddSubMenu("Fix")
				fix:AddOption( "Reopen URL", function()
					hnchat.lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
				end)
				fix:AddOption( "Reload", function()
					hnchat.lua.html:Refresh()
				end)
				fix:AddOption( "Reload (empty cache)", function()
					hnchat.lua.html:Refresh(true)
				end)
			local mode = menu:AddSubMenu("Mode")
				for k, v in pairs(modes) do
					mode:AddOption(k, function()
						hnchat.lua.html:Call([[editor.getSession().setMode("ace/mode/]]..v..[[");]])
					end)
				end
			local theme = menu:AddSubMenu("Theme")
				for k, v in SortedPairs(themes) do
					theme:AddOption(k, function()
						hnchat.lua.html:Call([[editor.setTheme("ace/theme/]]..v..[[");]])
					end)
				end
			local fontsize = menu:AddSubMenu("Font Size")
				for i=9, 24 do
					fontsize:AddOption( i.." px", function()
						hnchat.lua.html:Call("editor.setFontSize("..i..")")
					end)
				end

			menu:AddOption( "Legacy LuaDev", function()
				--hnchat.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "Performance", function()
				--hnchat.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:AddOption( "1 fps refresh", function()
				--hnchat.lua.html:Call([[editor.showSettingsMenu()]])
			end)
			menu:Open()
		end
		hnchat.lua.paddingone.run = vgui.Create( "DButton", hnchat.lua.paddingone )
		hnchat.lua.paddingone.run:SetIcon("icon16/cog_go.png")
		hnchat.lua.paddingone.run:SetText("Run")
		hnchat.lua.paddingone.run:Dock(LEFT)
		hnchat.lua.paddingone.run.DoClick = function(self)
			--print(hnchat.lua.html:Call([[editor.getValue()]]))
		end

		hnchat.lua.paddingtwo = vgui.Create( "DScrollPanel", hnchat.dFrame )
		hnchat.lua.paddingtwo:Dock( LEFT )
		hnchat.lua.paddingtwo.Paint = function( self, w, h )
			draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
		end

		hnchat.lua.paddingtwo.save = vgui.Create( "DButton", hnchat.lua.paddingtwo )
		hnchat.lua.paddingtwo.save:SetText("Save")
		hnchat.lua.paddingtwo.save:SetIcon("icon16/script_save.png")
		hnchat.lua.paddingtwo.save:Dock(TOP)
		hnchat.lua.paddingtwo.load = vgui.Create( "DButton", hnchat.lua.paddingtwo )
		hnchat.lua.paddingtwo.load:SetText("Load")
		hnchat.lua.paddingtwo.load:SetIcon("icon16/script_edit.png")
		hnchat.lua.paddingtwo.load:Dock(TOP)
		hnchat.lua.paddingtwo.open = vgui.Create( "DButton", hnchat.lua.paddingtwo )
		hnchat.lua.paddingtwo.open:SetText("Open")
		hnchat.lua.paddingtwo.open:SetIcon("icon16/folder_explore.png")
		hnchat.lua.paddingtwo.open:Dock(TOP)

		hnchat.lua.paddingtwo.loadurl = vgui.Create( "DButton", hnchat.lua.paddingtwo )
		hnchat.lua.paddingtwo.loadurl:SetText("Load URL")
		hnchat.lua.paddingtwo.loadurl:SetIcon("icon16/page_link.png")
		hnchat.lua.paddingtwo.loadurl.DoClick = function(self)
			Derma_StringRequest("Load URL","Paste in URL, pastebin and hastebin links are automatically in raw form.","",function(txt)
				if not txt:find("com/raw") then
					print("not raw")
				else
					print("fuckin raw")
				end
			end)
		end
		hnchat.lua.paddingtwo.loadurl:Dock(TOP)

		hnchat.lua.html = vgui.Create( "DHTML", hnchat.dFrame )
		hnchat.lua.html:Dock( FILL )
		hnchat.lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
		hnchat.lua.html:SetAllowLua( true )

		--[[
			[LEDITOR] InternalSnippetsUpdate -> function () { [native code] }
			[LEDITOR] OnCode -> function () { [native code] }
			[LEDITOR] OnLog -> function () { [native code] }
			[LEDITOR] OnReady -> function () { [native code] }
			[LEDITOR] OnSelection -> function () { [native code] }
			[LEDITOR] oncontextmenu -> function () { [native code] }
			[LEDITOR] onmousedown -> function () { [native code] }
		]]

	hnchat.settings = {}
		hnchat.settings.tab = vgui.Create( "DButton", hnchat.dFrame )
		hnchat.settings.tab.isActive = false
		hnchat.settings.tab:SetText("Settings")
		hnchat.settings.tab:SetPos(189,6)
		hnchat.settings.tab:SetSize( 73, 19 )
		hnchat.settings.tab.DoClick = function( self )
			hnchat.changetab( hnchat.settings )
		end
		hnchat.settings.tab.Paint = function( self, w, h )
			draw.RoundedBoxEx( 4, 0, 0, w, h, Color(255,255,255,200), self.isActive, self.isActive, false, false )
		end

		hnchat.settings.base = vgui.Create( "DCategoryList", hnchat.dFrame )
		hnchat.settings.base:Dock( FILL )

		hnchat.settings.chat = hnchat.settings.base:Add( "Chat" )
			hnchat.settings.chat:SetExpanded( false )

			hnchat.settings.chat.list = vgui.Create( "DPanelList", hnchat.settings.chat )
			hnchat.settings.chat.list:SetSpacing(7)
			hnchat.settings.chat.list:SetPadding(5)
			hnchat.settings.chat.list:EnableHorizontal(false)
			hnchat.settings.chat.list:EnableVerticalScrollbar(true)
			hnchat.settings.chat:SetContents( hnchat.settings.chat.list )

			for k, v in pairs(hnchat.config.chat) do
				hnchat.settings.chat.k = vgui.Create( "DCheckBoxLabel" )
				hnchat.settings.chat.k:SetText( v.label )
				hnchat.settings.chat.k:SetConVar( v.convar:GetName() )
				hnchat.settings.chat.k:SetValue( v.convar:GetBool() )
				hnchat.settings.chat.k:SizeToContents()
				hnchat.settings.chat.k:SetTextColor( Color( 3, 3, 3, 255 ) )
				hnchat.settings.chat.k:SetToolTip( v.desc )
				hnchat.settings.chat.list:AddItem( hnchat.settings.chat.k )
			end
		hnchat.settings.chathud = hnchat.settings.base:Add( "Chat HUD" )
			hnchat.settings.chathud:SetExpanded( false )
			--cock
		hnchat.settings.audio = hnchat.settings.base:Add( "Audio" )
			hnchat.settings.audio:SetExpanded( false )

			hnchat.settings.audio.list = vgui.Create( "DPanelList", hnchat.settings.audio )
			hnchat.settings.audio.list:SetSpacing(7)
			hnchat.settings.audio.list:SetPadding(5)
			hnchat.settings.audio.list:EnableHorizontal(false)
			hnchat.settings.audio.list:EnableVerticalScrollbar(true)
			hnchat.settings.audio:SetContents( hnchat.settings.audio.list )

			hnchat.settings.audio.outmute = vgui.Create( "DCheckBoxLabel" )
			hnchat.settings.audio.outmute:SetText( "Out of game mute" )
			hnchat.settings.audio.outmute:SetConVar( "snd_mute_losefocus" )
			hnchat.settings.audio.outmute:SetValue( GetConVar("snd_mute_losefocus"):GetBool() )
			hnchat.settings.audio.outmute:SizeToContents()
			hnchat.settings.audio.outmute:SetTextColor( Color( 3, 3, 3, 255 ) )
			hnchat.settings.audio.outmute:SetToolTip( "Mute in game sounds while tabbed out of game" )
			hnchat.settings.audio.list:AddItem( hnchat.settings.audio.outmute )
		hnchat.settings.graphics = hnchat.settings.base:Add( "Performance / Graphics" )
			hnchat.settings.graphics:SetExpanded( false )
			--COCK
		hnchat.settings.dms = hnchat.settings.base:Add( "PM" )
			hnchat.settings.dms:SetExpanded( false )
			--CCCCOCK
		hnchat.settings.game = hnchat.settings.base:Add( "Game" )
			hnchat.settings.game:SetExpanded( false )

			hnchat.settings.game.list = vgui.Create( "DPanelList", hnchat.settings.game )
			hnchat.settings.game.list:SetSpacing(7)
			hnchat.settings.game.list:SetPadding(5)
			hnchat.settings.game.list:EnableHorizontal(false)
			hnchat.settings.game.list:EnableVerticalScrollbar(true)
			hnchat.settings.game:SetContents( hnchat.settings.game.list )

			hnchat.settings.game.netgraph = {}
			for i=1, 4 do
				hnchat.settings.game.netgraph.i = vgui.Create( "DCheckBoxLabel" )
				hnchat.settings.game.netgraph.i:SetText( "Net Graph " .. i )
				hnchat.settings.game.netgraph.i.val = i
				--[[hnchat.settings.game.netgraph.i.OnChange = function( self, val )
					if val then
						LocalPlayer():ConCommand( "net_graph " .. self.val )
						for k, v in pairs(hnchat.settings.game.netgraph) do
							print(k,v)
						end
					else
						LocalPlayer():ConCommand( "net_graph 0" )
					end
				end]]
				hnchat.settings.game.netgraph.i:SetValue( 0 )
				hnchat.settings.game.netgraph.i:SizeToContents()
				hnchat.settings.game.netgraph.i:SetTextColor( Color( 3, 3, 3, 255 ) )
				hnchat.settings.game.netgraph.i:SetToolTip( "Set net graph value to " .. i )
				hnchat.settings.game.list:AddItem( hnchat.settings.game.netgraph.i )
			end
			for k, v in pairs(hnchat.settings.game.netgraph) do
				--print(k,v)
			end
		hnchat.settings.media = hnchat.settings.base:Add( "Media Player" )
			hnchat.settings.media:SetExpanded( false )
			-- PAPALI PAPALI SUKA

	hnchat.globalchat.RichText:InsertColorChange( 255, 111, 52, 255 )
	--hnchat.globalchat.RichText:AppendText( "Hello and, again, welcome to " .. GetHostName() .. ", " .. LocalPlayer():UndecorateNick() .. ". " )
	hnchat.globalchat.RichText:AppendText( "We hope your brief detention in the loading screen has been a pleasant one. " )
	hnchat.globalchat.RichText:AppendText( "Your specimen has been processed and we are now ready to begin the game proper. " )
	hnchat.globalchat.RichText:AppendText( "Before we start, however, keep in mind that, although fun is the primary goal of of all server activities, serious injuries may occur. " )
	hnchat.globalchat.RichText:AppendText( "For your own safety, and the safety of others, please refrain from being a cunt. ")
	hnchat.globalchat.RichText:AppendText( "The time is " .. GetTime( hnchat.config.chat.time_24h.convar:GetBool() ) .. ". Current map is " .. game.GetMap() )

	--[[hook.Add( "HUDShouldDraw", "hnchat", function( name )
		if name == "CHudChat" then
			return false
		end
	end )]]

	hook.Add( "ChatText", "hnchat", function( index, name, txt, type )
		if type == "joinleave" or type == "none" then
			hnchat.globalchat.RichText:AppendText( "\n" )
			if hnchat.config.chat.time_stamps.convar:GetBool() then
				hnchat.globalchat.RichText:InsertColorChange( 119, 171, 218, 255 )
				hnchat.globalchat.RichText:AppendText( GetTime( hnchat.config.chat.time_24h.convar:GetBool() ) )

				hnchat.globalchat.RichText:InsertColorChange( 255, 255, 255, 255 )
				hnchat.globalchat.RichText:AppendText(" - ")
			end
			hnchat.globalchat.RichText:InsertColorChange( 255, 255, 255, 255 )
			hnchat.globalchat.RichText:AppendText( txt )
		elseif type == "namechange" then
			--[[
				Index: 0
				Name: Console
				Txt: Player homonovus changed name to homonovus.test
				Type: namechange
			]]
		else
			print( "Index: " .. index )
			print( "Name: " .. name )
			print( "Txt: " .. txt )
			print( "Type: " .. type )
		end
	end )

	hook.Add( "PlayerBindPress", "hnchat", function( ply, bind, pressed )
		
		if bind:find( "messagemode2" ) then
			hnchat.openChatbox( "lua" )
			return true
		elseif bind:find( "messagemode" ) then
			hnchat.openChatbox( "global" )
			return true
		end
	end )

	net.Receive("hnchat_local_toplayers", function( len )
		local ply = net.ReadEntity()
		local txt = net.ReadString()

		chat.AddText( Color(24,161,35), "(Local) ", ply, Color(255,255,255), ": " .. txt )
	end)
	hnchat.closeChatbox()
end)