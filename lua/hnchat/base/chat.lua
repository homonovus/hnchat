local localtag = "hnchat_local"
local saytag = "hnchat_say"

if SERVER then
	util.AddNetworkString(localtag)
	util.AddNetworkString(saytag)

	net.Receive( localtag, function(len,ply)
		local plys = net.ReadTable()
		local txt = net.ReadString():gsub("\n","")
		local msg = gamemode.Call( "PlayerSay", ply, txt, false )
		if type(msg) ~= "string" or string.Trim(msg) == "" then return end

		net.Start( localtag, false )
			net.WriteEntity(ply)
			net.WriteString(msg)
		net.Send(plys)
	end)
	net.Receive( saytag, function(len,ply)
		local txt = net.ReadString():gsub("\n","")
		local team = net.ReadBool()
		local msg = gamemode.Call( "PlayerSay", ply, txt, team )
		if type(msg) ~= "string" or string.Trim(msg) == "" then return end

		net.Start( saytag )
			net.WriteEntity(ply)
			net.WriteString(msg)
			net.WriteBool(team)
		net.Broadcast()
	end)

	return
end

if not hnchat then return end

local hnchat_timestamps = CreateClientConVar( "hnchat_timestamps", 1 )
local hnchat_timestamps_24hr = CreateClientConVar( "hnchat_timestamps_24hr", 1 )
local hnchat_greentext = CreateClientConVar( "hnchat_greentext", 1 )
local hnchat_highlight = CreateClientConVar( "hnchat_highlight", 1 )
local hnchatbox_history_font = CreateClientConVar( "hnchatbox_history_font", "DermaDefault" )
local hnchatbox_font_input = CreateClientConVar( "hnchatbox_font_input", "DermaDefault" )

local hchat = vgui.Create("DPanel")

oldSay = Say
function Say( ... )
	local tab = {...}

	local txt = ""
	local team
	if isbool(tab[#tab]) then
		team = tab[#tab]
		table.remove(tab, #tab)
	end

	for k, v in next, tab do
		txt = txt..tostring(v).." "
	end
	txt = txt:Trim()

	net.Start( saytag, false )
		net.WriteString(txt)
		net.WriteBool(team)
	net.SendToServer()
end
function SayLocal(...)
	local meme = { Color(255,0,0), "(Local @ " }
	local sphere = ents.FindInSphere( LocalPlayer():GetPos(), 196 )
	local txt = ""

	for k, v in next, {...} do
		txt = txt..tostring(v).." "
	end
	txt = txt:Trim()

	net.Start( localtag, false )
		local plys = {}
		for k, v in next, sphere do
			if IsValid(v) and v:IsPlayer() then
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
end

hchat.Paint = function() return false end
hchat.RichText = vgui.Create( "RichText", hchat )
hchat.RichText:Dock(FILL)
hchat.RichText.Paint = function( self, w ,h )
	draw.RoundedBox( 0, 0, 0, w, h, Color(22,22,22,196))
end
cvars.AddChangeCallback( "hnchatbox_history_font", function( cmd, old, new)
	hchat.RichText:PerformLayout()
end)
hchat.RichText.PerformLayout = function( self )
	self:SetFontInternal(GetConVar("hnchatbox_history_font"):GetString())
	self:SetFGColor(Color(255,255,255,128))
end
hchat.RichText.ActionSignal = function( self, signalName, signalValue )
	if ( signalName == "TextClicked" ) then
		gui.OpenURL(signalValue)
	end
end

hchat.message = vgui.Create( "DSizeToContents", hchat )
hchat.message:Dock(BOTTOM)
hchat.message:SetTall(14)
hchat.TextEntry = vgui.Create( "DTextEntry", hchat.message )
hchat.TextEntry:Dock(FILL)
hchat.TextEntry:SetMultiline(true)
hchat.TextEntry.OldThink = hchat.TextEntry.Think
hchat.TextEntry.Think = function(self)
	if self.reqfocus then
		self:RequestFocus()
		self.reqfocus = false
	end
	gamemode.Call( "ChatTextChanged", self:GetText() )
	self.OldThink(self)
end
cvars.AddChangeCallback( "hnchatbox_font_input", function( cmd, old, new)
	if new == old then return end

	hchat.TextEntry:SetFont(new)
	hchat.TextEntry:ApplySchemeSettings()

	return
end)
hchat.TextEntry.Paint = function( self, w ,h )
	local col = self.HistoryPos == 0 and Color(255,255,255,255) or Color(241,201,151,255)
	draw.RoundedBox( 0, 0, 0, w, h, col )
	self:DrawTextEntryText( Color(0,0,0,255), Color(24,131,255,255), Color(0,0,0,255) )
	return false
end
hchat.TextEntry.OnKeyCodeTyped = function( self, key )
	if key == KEY_ENTER then
		local str = self:GetText():Trim()

		self:AddHistory(str)
		self:SetText("")
		if str ~= "" then
			if hchat.msgmode.curtype == 1 then
				Say( str, false )
			elseif hchat.msgmode.curtype == 2 then
				Say( str, true )
			elseif hchat.msgmode.curtype == 3 then
				SayLocal(str)
			elseif hchat.msgmode.curtype == 4 then
				RunConsoleCommand( "saysound", str )
			elseif hchat.msgmode.curtype == 5 then
				LocalPlayer():ConCommand(str)
			else
				Say( str, false )
			end
		end

		self.HistoryPos = 0
		hnchat.closeChatbox()
	end
	if key == KEY_UP then
		self.HistoryPos = self.HistoryPos - 1
		self:UpdateFromHistory()
	end
	if key == KEY_DOWN then
		self.HistoryPos = self.HistoryPos + 1
		self:UpdateFromHistory()
	end
	if key == KEY_TAB then
		self.reqfocus = true
		if self:GetText() == "" or not self:GetText() then
			if input.IsControlDown() then
				hchat.msgmode.curtype = hchat.msgmode.curtype > 1 and hchat.msgmode.curtype - 1 or #hchat.msgmode.types
			else
				hchat.msgmode.curtype = hchat.msgmode.curtype < #hchat.msgmode.types and hchat.msgmode.curtype + 1 or 1
			end
		else
			local tab = hook.Run( "OnChatTab", self:GetText() )

			if tab and isstring(tab) and tab ~= self:GetText() then
				self:SetText(tab)
			end
		end
		self:SetCaretPos(#self:GetText())
	end
end
hchat.msgmode = vgui.Create("DButton", hchat.message )
hchat.msgmode:Dock(LEFT)
hchat.msgmode.curtype = 1
hchat.msgmode.types = {
		{
			name = "Say",
			icon = "icon16/world",
			size = {
				x = 31,
				y = 16
			}
		},
		{
			name = "Say (TEAM)",
			icon = "icon16/world_link",
			size = {
				x = 69,
				y = 16
			}
		},
		{
			name = "local chat",
			icon = "icon16/transmit_blue",
			size = {
				x = 58,
				y = 16
			}
		},
		{
			name = "Console",
			icon = "icon16/application_xp_terminal",
			size = {
				x = 51,
				y = 16
			}
		},
		{
			name = "Language",
			icon = "icon16/font",
			size = {
				x = 60,
				y = 16
			}
		}
}

if concommand.GetTable().saysound then
	table.insert(hchat.msgmode.types,4,{
		name = "Voice",
		icon = "icon16/phone_sound",
		size = {
			x = 38,
			y = 16
		}
	})
end

hchat.msgmode.Think = function( self )
	local type = self.types[self.curtype]
	self:SetText( type.name )
	self:SetSize( type.size.x, type.size.y)
end
hchat.msgmode.OnMousePressed = function ( self, mc )
	if mc == MOUSE_LEFT then
		self.curtype = self.curtype < #self.types and self.curtype + 1 or 1
	else
		local menu = DermaMenu()
		for k, v in next, self.types do
			menu:AddOption( v.name, function()
				self.curtype = k
			end ):SetIcon( v.icon .. ".png")
		end
		menu:Open()
	end
	hchat.TextEntry:RequestFocus()
end

local function extrashit( self )
	if hnchat_timestamps:GetBool() then
		self:InsertColorChange( 119, 171, 218, 255 )
		self:AppendText( hnchat_timestamps_24hr:GetBool() and (os.date("%H:%M", os.time())) or (os.date("%I:%M %p", os.time())) )

		self:InsertColorChange( 255, 255, 255, 255 )
		self:AppendText(" - ")
	end
end

hnchat.IsURL = function(str)
	local LinkPatterns = {
		"https?://[^%s%\"]+",
		"ftp://[^%s%\"]+",
		"steam://[^%s%\"]+",
	}
	for index,pattern in pairs(LinkPatterns) do
		if string.match(str,pattern) then
			return true
		end
	end
	return false
end

hnchat.AddText = function( self, ... )
	local tab = {...}

	extrashit( self )

	self:InsertColorChange(152,212,255,255)

	if #tab == 1 and isstring(tab[1]) then
		self:AppendText(tab[1])
		self:AppendText("\n")

		return
	end

	for k, v in next, tab do
		if IsColor(v) then
			self:InsertColorChange(v.r, v.g, v.b, 255)
		elseif type(v) == "string"  then
			local words = string.Explode(" ",v)
			if IsValid(LocalPlayer()) and (v:find(LocalPlayer():Nick()) or v:find(LocalPlayer():UndecorateNick())) and hnchat_highlight:GetBool() then
				self:InsertColorChange( 255, 90, 35, 255 )
			end

			if v:sub(3, 3):find(">") and hnchat_greentext:GetBool() then
				self:InsertColorChange( 46, 231, 46, 255)
			end

			local mup = markup.Parse(v, 0)
			local lastcol

			-- my attempt at colors in richtext
			--[[for k1,v1 in next, mup.blocks do
				local col = Color(v1.colour.r,v1.colour.g,v1.colour.b,v1.colour.a or 255)

				lastcol = col
				self:InsertColorChange(col.r,col.g,col.b,col.a)

				local words = string.Explode(" ", v1.text)]]

				for k2, v2 in next, words do
					if hnchat.IsURL(v2) then
						local url = string.gsub(v2,"^%s:","")
						self:InsertClickableTextStart(url)
						self:AppendText(url)
						self:InsertClickableTextEnd()
					else
						self:AppendText(v2.." ")
					end
				end
			--end
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
		else
			self:AppendText(tostring(v))
		end
	end
	self:AppendText("\n")
end

oldChatAddText = oldChatAddText or chat.AddText
function chat.AddText(...)
	hnchat.AddText( hchat.RichText, ... )
	if chathud and chat.AddText then chathud.AddText(...) end
	oldChatAddText(...)
end

net.Receive(saytag,function()
	local ply = net.ReadEntity()
	local msg = net.ReadString()
	local team = net.ReadBool()

	gamemode.Call("OnPlayerChat", ply, msg, team, not ply:Alive())
end)

net.Receive(localtag,function()
	local ply = net.ReadEntity()
	local msg = net.ReadString()

	chat.AddText( Color(24,161,35,255), "(Local) ", ply, color_white, ": "..msg )
end)

hook.Add("ChatText", "hnchat", function(idx, name, text, type)
	if type == "chat" then
		hnchat.AddText(hchat.RichText, name, color_white, ": ", text.."\n")
		return
	end

	hnchat.AddText(hchat.RichText, text)
end)
hook.Add("FinishChat", "hnchat", function()
	hchat.TextEntry:SetText("")
	hchat.msgmode.curtype = 1
	gamemode.Call( "ChatTextChanged", "" )
end)
concommand.Add( "hnchat_open",function() -- opens chat
	hnchat.openChatbox()
	hchat.TextEntry:RequestFocus()
end)
concommand.Add( "hnchat_open_local",function() -- opens chat in local
	RunConsoleCommand("hnchat_open")
	hchat.msgmode.curtype = 3
end)
concommand.Add( "hnchat_open_team",function() -- open chat in team
	RunConsoleCommand("hnchat_open")
	hchat.msgmode.curtype = 2
end)

return hnchat.derma.tabs:AddSheet( "Global", hchat, "icon16/comments.png", false, false, "Chat" )
