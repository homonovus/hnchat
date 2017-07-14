--if hnchat then hnchat.UnLoad() end

local hnchat_disable = CreateClientConVar("hnchat_disable", 0)
if hnchat_disable:GetBool() then return end

hook.Add( "Initialize", "hnchat", function()
	hook.Remove( "Initialize", "hnchat" )

	hnchat = hnchat or {}
	oldchatgui = oldchatgui or chatgui
	local hnchat_timestamps = CreateClientConVar( "hnchat_timestamps", 1 )
	local hnchat_timestamps_24hr = CreateClientConVar( "hnchat_timestamps_24hr", 1 )
	local hnchat_greentext = CreateClientConVar( "hnchat_greentext", 1 )
	local hnchat_highlight = CreateClientConVar( "hnchat_highlight", 1 )
	local hnchatbox_history_font = CreateClientConVar( "hnchatbox_history_font", "DermaDefault" )
	local hnchatbox_font_input = CreateClientConVar( "hnchatbox_font_input", "DermaDefault" )

	function hnchat.tofull()
		hnchat.derma.Frame:SetCookie("full",1)
		local x, y = hnchat.derma.Frame:GetPos()
		local w, h = hnchat.derma.Frame:GetSize()
		hnchat.derma.Frame:SetCookie("x",x)
		hnchat.derma.Frame:SetCookie("y",y)
		hnchat.derma.Frame:SetCookie("w",w)
		hnchat.derma.Frame:SetCookie("h",h)

		hnchat.derma.Frame:SetSize(ScrW(), ScrH())
		hnchat.derma.Frame:SetPos(0,0)
		hnchat.derma.Frame:SetDraggable(false)

		hnchat.derma.Frame.FSButton.DoClick = hnchat.towin
	end
	function hnchat.towin()
		hnchat.derma.Frame:SetCookie("full",0)
		local x = hnchat.derma.Frame:GetCookie("x",x)
		local y = hnchat.derma.Frame:GetCookie("y",y)
		local w = hnchat.derma.Frame:GetCookie("w",w)
		local h = hnchat.derma.Frame:GetCookie("h",h)

		hnchat.derma.Frame:SetDraggable(true)
		hnchat.derma.Frame:SetPos(x,y)
		hnchat.derma.Frame:SetSize(w,h)

		hnchat.derma.Frame.FSButton.DoClick = hnchat.tofull
	end
	function hnchat.closeChatbox()
		hnchat.derma.Frame:SetMouseInputEnabled( false )
		hnchat.derma.Frame:SetKeyboardInputEnabled( false )
		gui.EnableScreenClicker( false )
		hnchat.derma.Frame:SetVisible( false )

		gamemode.Call( "ChatTextChanged", "" )
		gamemode.Call( "FinishChat" )
	end
	function hnchat.openChatbox(mode)
		mode = mode or "Global"
		hnchat.derma.Frame:SetVisible(true)
		hnchat.derma.Frame:MakePopup()

		hnchat.derma.tabs:SwitchToName(mode)

		gamemode.Call("StartChat")
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
			if key == KEY_F11 then hnchat.derma.Frame.FSButton.DoClick() end
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

	hnchat.derma.chat = include("hnchat/base/chat.lua")
	hnchat.derma.dms = include("hnchat/base/dms.lua")
	local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer.Tab.Paint = function(self) return false end
		spacer.Tab:SetEnabled(false)
		spacer.Tab:SetCursor("arrow")
		local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
		spacer.Tab.Paint = function(self) return false end
		spacer.Tab:SetEnabled(false)
		spacer.Tab:SetCursor("arrow")
	hnchat.derma.lua = include("hnchat/base/lua.lua")
	hnchat.derma.config = include("hnchat/base/config.lua")

	local files, dir = file.Find( "hnchat/modules/*", "LUA" )
	for k, v in next, files do
		if (k%2==0) then
			local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
			spacer.Tab.Paint = function(self) return false end
			spacer.Tab:SetEnabled(false)
			spacer.Tab:SetCursor("arrow")
			local spacer = hnchat.derma.tabs:AddSheet( "", vgui.Create( "DPanel" ) )
			spacer.Tab.Paint = function(self) return false end
			spacer.Tab:SetEnabled(false)
			spacer.Tab:SetCursor("arrow")
		end
		local name = string.gsub( v, "%plua", "" )
		hnchat.derma[name] = include("hnchat/modules/" .. v)
	end

	hnchat.derma.Frame.CloseButton = vgui.Create( "DButton", hnchat.derma.Frame )
	hnchat.derma.Frame.CloseButton:SetSize( 42, 16 )
	hnchat.derma.Frame.CloseButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(255,0,0) or Color(255,62,62)

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, false, true )
		draw.SimpleTextOutlined( "r", "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black )
		return true
	end
	hnchat.derma.Frame.CloseButton.DoClick = function(self)
		hnchat.closeChatbox()
	end
	hnchat.derma.Frame.CloseButton.oldThink = hnchat.derma.Frame.CloseButton.Think
	hnchat.derma.Frame.CloseButton.Think = function(self)
		local x, y = self:GetParent():GetSize()
		self:SetPos( x - 46, 0 )
		self.oldThink(self)
	end

	hnchat.derma.Frame.FSButton = vgui.Create( "DButton", hnchat.derma.Frame )
	hnchat.derma.Frame.FSButton:SetText("")
	hnchat.derma.Frame.FSButton:SetSize( 24, 16 )
	hnchat.derma.Frame.FSButton.Paint = function( self, w, h )
		local col = self:IsHovered() and Color(128,128,128) or Color(177,177,177)
		local symbol = (self:GetParent():GetCookie("full", 0) == 1 ) and "2" or "1"

		draw.RoundedBoxEx( 4, 0, 0, w, h, col, false, false, true, false )
		draw.SimpleTextOutlined(symbol, "Marlett", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
		return true
	end
	hnchat.derma.Frame.FSButton.oldThink = hnchat.derma.Frame.FSButton.Think
	hnchat.derma.Frame.FSButton.Think = function(self)
		local x, y = self:GetParent():GetSize()
		self:SetPos( x - 70, 0 )
		self.oldThink(self)
	end
	hnchat.derma.Frame.FSButton.DoClick = hnchat.tofull

	hook.Add( "PlayerBindPress", "hnchat", function( ply, bind, pressed )
		if bind:find("messagemode2") then
			RunConsoleCommand("hnchat_open")
			hnchat.derma.chat.msgmode.curtype = 1
			return true
		elseif bind:find("messagemode") then
			RunConsoleCommand("hnchat_open")
			return true
		end
	end)

	local oldClose = chat.Close
	local oldOpen = chat.Open
	local oldPos = chat.GetChatBoxPos
	local oldSize = chat.GetChatBoxSize

	function chat.Close() 
		hnchat.closeChatbox()
	end
	function chat.Open()
		hnchat.openChatbox()
	end
	function chat.GetChatBoxPos()
		return hnchat.derma.Frame:GetPos()
	end
	function chat.GetChatBoxSize()
		return hnchat.derma.Frame:GetSize()
	end

	function hnchat.UnLoad()
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

		-- empty
		table.Empty(hnchat)
		chatgui = oldchatgui or nil
		oldchatgui = nil
	end

	hnchat.closeChatbox()
end)
