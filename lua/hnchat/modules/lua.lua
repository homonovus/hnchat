if not hnchat then return end

luastuff = vgui.Create("DPanel")
luastuff.Paint = function() return false end
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

luastuff.topbar = vgui.Create( "DHorizontalScroller", luastuff )
luastuff.topbar:Dock(TOP)
luastuff.topbar.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
end
luastuff.topbar:SetOverlap(0)

luastuff.topbar.menu = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.menu:SetIcon("icon16/application_form_edit.png")
luastuff.topbar.menu:SetText("Menu")
luastuff.topbar.menu:Dock(LEFT)
luastuff.topbar.menu.Paint = ezdraw
luastuff.topbar.menu.DoClick = function(self)
	local menu = DermaMenu()
	menu:AddOption( "Configure", function()
		luastuff.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:AddOption( "Toggle left panel", function()
		luastuff.leftbar:SetVisible(not luastuff.leftbar:IsVisible())
		luastuff.html:Dock(FILL) -- TODO: get that shit to auto do this
	end)
	menu:AddOption( "Show Help", function()
		luastuff.html:Call([[editor.showKeyboardShortcuts()]])
	end)

	local fix = menu:AddSubMenu("Fix")
		fix:AddOption( "Reopen URL", function()
			luastuff.html:OpenURL("http://metastruct.github.io/lua_editor/")
		end)
		fix:AddOption( "Reload", function()
			luastuff.html:Refresh()
		end)
		fix:AddOption( "Reload (empty cache)", function()
			luastuff.html:Refresh(true)
		end)
	local mode = menu:AddSubMenu("Mode")
		for k, v in pairs(modes) do
			mode:AddOption(k, function()
				luastuff.html:Call([[editor.getSession().setMode("ace/mode/]]..v..[[");]])
			end)
		end
	local theme = menu:AddSubMenu("Theme")
		for k, v in SortedPairs(themes) do
			theme:AddOption(k, function()
				luastuff.html:Call([[editor.setTheme("ace/theme/]]..v..[[");]])
			end)
		end
	local fontsize = menu:AddSubMenu("Font Size")
		for i=9, 24 do
			fontsize:AddOption( i.." px", function()
				luastuff.html:Call("editor.setFontSize("..i..")")
			end)
		end

	menu:AddOption( "Legacy LuaDev", function()
		--luastuff.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:AddOption( "Performance", function()
		--luastuff.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:AddOption( "1 fps refresh", function()
		--luastuff.html:Call([[editor.showSettingsMenu()]])
	end)
	menu:Open()
end
luastuff.topbar:AddPanel(luastuff.topbar.menu)

local spacer = vgui.Create("DPanel", luastuff.topbar)
	spacer:SetSize(32,24)
	spacer:Dock(LEFT)
	spacer.Paint = function(self) return false end
	luastuff.topbar:AddPanel(spacer)

luastuff.topbar.run = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.run:SetIcon("icon16/cog_go.png")
luastuff.topbar.run:SetText("Run")
luastuff.topbar.run:SetSize(55,24)
luastuff.topbar.run:Dock(LEFT)
luastuff.topbar.run.Paint = function(self, w, h)
	col = self:IsHovered() and Color(222,222,222) or Color(190,243,188)
	textcol = self:IsHovered() and Color(96,42,180) or Color(81,81,81)
	textcol = self:IsDown() and color_white or textcol

	draw.RoundedBox( 0, 0, 0, w, h, col)
	draw.SimpleText( self:GetText(), "DermaDefault", w/2, h/2, textcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return true
end
luastuff.topbar.run.DoClick = function(self)
	--print(luastuff.html:Call([[editor.getValue()]]))
end
luastuff.topbar:AddPanel(luastuff.topbar.run)

luastuff.topbar.server = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.server:SetIcon("icon16/server.png")
luastuff.topbar.server:SetText("Server")
luastuff.topbar.server:SetSize(68,24)
luastuff.topbar.server:Dock(LEFT)
luastuff.topbar.server.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.server)

luastuff.topbar.clients = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.clients:SetIcon("icon16/group.png")
luastuff.topbar.clients:SetText("Clients")
luastuff.topbar.clients:SetSize(68,24)
luastuff.topbar.clients:Dock(LEFT)
luastuff.topbar.clients.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.clients)

luastuff.topbar.shared = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.shared:SetIcon("icon16/world.png")
luastuff.topbar.shared:SetText("Shared")
luastuff.topbar.shared:SetSize(70,24)
luastuff.topbar.shared:Dock(LEFT)
luastuff.topbar.shared.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.shared)

local spacer = vgui.Create("DPanel", luastuff.topbar)
	spacer:SetSize(16,24)
	spacer:Dock(LEFT)
	spacer.Paint = function() return false end
	luastuff.topbar:AddPanel(spacer)

luastuff.topbar.player = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.player:SetIcon("icon16/user.png")
luastuff.topbar.player:SetText("Player")
luastuff.topbar.player:SetSize(66,24)
luastuff.topbar.player:Dock(LEFT)
luastuff.topbar.player.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.player)

luastuff.topbar.devs = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.devs:SetIcon("icon16/user_gray.png")
luastuff.topbar.devs:SetSize(60,24)
luastuff.topbar.devs:SetText("Devs")
luastuff.topbar.devs:Dock(LEFT)
luastuff.topbar.devs.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.devs)

luastuff.topbar.near = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.near:SetIcon("icon16/group.png")
luastuff.topbar.near:SetText("Nearby")
luastuff.topbar.near:SetSize(71,24)
luastuff.topbar.near:Dock(LEFT)
luastuff.topbar.near.Paint = ezdraw
luastuff.topbar:AddPanel(luastuff.topbar.near)

local spacer = vgui.Create("DPanel", luastuff.topbar)
	spacer:SetSize(16,24)
	spacer:Dock(LEFT)
	spacer.Paint = function() return false end
	luastuff.topbar:AddPanel(spacer)

luastuff.topbar.servers = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.servers:SetIcon("icon16/server_lightning.png")
luastuff.topbar.servers:SetText("Servers")
luastuff.topbar.servers:Dock(LEFT)
luastuff.topbar.servers:SetSize(85,24)
luastuff.topbar.servers:SetEnabled(false)
luastuff.topbar:AddPanel(luastuff.topbar.servers)

luastuff.topbar.javascript = vgui.Create( "DButton", luastuff.topbar )
luastuff.topbar.javascript:SetIcon("icon16/script_gear.png")
luastuff.topbar.javascript:SetText("Javascript")
luastuff.topbar.javascript:Dock(LEFT)
luastuff.topbar.javascript:SetSize(85,24)
luastuff.topbar.javascript:SetEnabled(false)
luastuff.topbar:AddPanel(luastuff.topbar.javascript)


luastuff.leftbar = vgui.Create( "DScrollPanel", luastuff )
luastuff.leftbar:Dock(LEFT)
luastuff.leftbar.Paint = function( self, w, h )
	draw.RoundedBox( 3, 0, 0, w, h, Color(234,234,234,255))
end

luastuff.leftbar.save = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.save:SetText("Save")
luastuff.leftbar.save:SetIcon("icon16/script_save.png")
luastuff.leftbar.save.Paint = ezdraw
luastuff.leftbar.save:Dock(TOP)

luastuff.leftbar.load = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.load:SetText("Load")
luastuff.leftbar.load:SetIcon("icon16/script_edit.png")
luastuff.leftbar.load.Paint = ezdraw
luastuff.leftbar.load:Dock(TOP)

luastuff.leftbar.open = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.open:SetText("Open")
luastuff.leftbar.open:SetIcon("icon16/folder_explore.png")
luastuff.leftbar.open.Paint = ezdraw
luastuff.leftbar.open:Dock(TOP)

local spacer = vgui.Create("DPanel", luastuff.leftbar)
	spacer:SetSize(74,8)
	spacer:Dock(TOP)
	spacer.Paint = function() return false end

luastuff.leftbar.loadurl = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.loadurl:SetText("Load URL")
luastuff.leftbar.loadurl:SetIcon("icon16/page_link.png")
luastuff.leftbar.loadurl.DoClick = function(self)
	Derma_StringRequest("Load URL","Paste in URL, pastebin and hastebin links are automatically in raw form.","",function(txt)
		if not txt:find("com/raw") then
			print("not raw")
		else
			print("fuckin raw")
		end
	end)
end
luastuff.leftbar.loadurl.Paint = ezdraw
luastuff.leftbar.loadurl:Dock(TOP)

local spacer = vgui.Create("DPanel", luastuff.leftbar)
	spacer:SetSize(74,8)
	spacer:Dock(TOP)
	spacer.Paint = function() return false end

luastuff.leftbar.pastebin = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.pastebin:SetText("pastebin")
luastuff.leftbar.pastebin:SetIcon("icon16/page_link.png")
luastuff.leftbar.pastebin.Paint = ezdraw
luastuff.leftbar.pastebin:Dock(TOP)

luastuff.leftbar.send = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.send:SetText("Send")
luastuff.leftbar.send:SetIcon("icon16/email_go.png")
luastuff.leftbar.send.Paint = ezdraw
luastuff.leftbar.send:Dock(TOP)

luastuff.leftbar.receive = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.receive:SetText("Receive")
luastuff.leftbar.receive:SetIcon("icon16/email_open.png")
luastuff.leftbar.receive.Paint = ezdraw
luastuff.leftbar.receive:Dock(TOP)

local spacer = vgui.Create("DPanel", luastuff.leftbar)
	spacer:SetSize(74,8)
	spacer:Dock(TOP)
	spacer.Paint = function() return false end

luastuff.leftbar.beauty = vgui.Create( "DButton", luastuff.leftbar )
luastuff.leftbar.beauty:SetText("Beautify")
luastuff.leftbar.beauty:SetIcon("icon16/font.png")
luastuff.leftbar.beauty.Paint = ezdraw
luastuff.leftbar.beauty:Dock(TOP)

local spacer = vgui.Create("DPanel", luastuff.leftbar)
	spacer:SetSize(74,8)
	spacer:Dock(TOP)
	spacer.Paint = function() return false end

-- send as shit here

local spacer = vgui.Create("DPanel", luastuff.leftbar)
	spacer:SetSize(74,8)
	spacer:Dock(TOP)
	spacer.Paint = function() return false end

-- easy lua combo box here

luastuff.prop = vgui.Create( "DPropertySheet", luastuff )
luastuff.prop:Dock(FILL)
luastuff.prop.Paint = function() return false end

-- propertysheet (done)
-- drag base (might be built into property sheet's tabs)
-- then tabs

--[[luastuff.html = vgui.Create( "DHTML", luastuff )
luastuff.html:Dock(FILL)
luastuff.html:OpenURL("http://metastruct.github.io/lua_editor/")
luastuff.html:SetAllowLua(true)]]

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

return luastuff