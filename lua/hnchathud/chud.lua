--[[
TODO:
    - own markup system so we can have < and > work properly when not tagged
    - more font options
    - config menu
    - parse names
--]]

chathud = chathud or {}
chathud.shortcuts = chathud.shortcuts or {}

local hnchat_legacy = GetConVar"hnchat_legacy"
local hnchat_greentext = GetConVar"hnchat_greentext"
local hnchat_highlight = GetConVar"hnchat_highlight"
local hnchat_timestamps = GetConVar"hnchat_timestamps"
local hnchat_timestamps_24hr = GetConVar"hnchat_timestamps_24hr"

chathud.cvars = {
    color      = CreateClientConVar("chathud_printcolor",     "152 212 255", true, false, "Sets default chat message color for non-player messages."),
    font       = CreateClientConVar("chathud_font",           "Verdana",     true, false, "Font face for the chathud."),
    fweight    = CreateClientConVar("chathud_font_weight",    600,           true, false, "Font weight, or boldness."),
    fsize      = CreateClientConVar("chathud_font_size",      17,            true, false, "Font size."),
}

local function CreateFont()
    surface.CreateFont("chathud_font",{
        font = chathud.cvars.font:GetString() or "Verdana",
        size = chathud.cvars.fsize:GetInt() or 17,
        antialias = true,
        shadow = true,
        weight = chathud.cvars.fweight:GetInt() or 600,
        extended = true,
        prettyblur = 1,
    })

    chathud.msgs = {}
end
CreateFont()
cvars.AddChangeCallback("chathud_font", CreateFont, "chathud_font")
cvars.AddChangeCallback("chathud_font_weight", CreateFont, "chathud_font_weight")
cvars.AddChangeCallback("chathud_font_size", CreateFont, "chathud_font_size")

local function ColToMarkup(col)
    return ("<color=%d,%d,%d>"):format(col.r,col.g,col.b)
end

chathud.msgs = {}

function chathud.AddMessage(msg)
    local out = {decay=CurTime()+10,alpha=255}
	local w = ScrW()*GetConVar"chathud_width":GetFloat()
    out.msg = markup.Parse("<font=chathud_font>"..msg, w)

    table.insert(chathud.msgs,out)
end

function chathud.AddText(...)
    local inp = {...}
    local tbl = {}

    table.insert(tbl,("<color=%s>"):format(chathud.cvars.color:GetString():gsub(" ",",")))

    if table.Count(inp) == 1 and isstring(inp[1]) then
		table.insert(tbl,inp[1])
        chathud.AddMessage(table.concat(tbl))
		return
	end

    if hnchat_timestamps:GetBool() then
		table.insert(tbl,ColToMarkup(Color(119, 171, 218)))
		table.insert(tbl,hnchat_timestamps_24hr:GetBool() and os.date("%H:%M", os.time()) or os.date("%I:%M %p", os.time()))

		table.insert(tbl,ColToMarkup(Color(255, 255, 255)))
		table.insert(tbl," - ")
	end

    for k, v in next, inp do
		if IsColor(v) then
			table.insert(tbl,ColToMarkup(v))
		elseif type(v) == "string"  then
			if IsValid(LocalPlayer()) and (v:find(LocalPlayer():Nick()) or v:find(LocalPlayer():UndecorateNick())) and hnchat_highlight:GetBool() then
				table.insert(tbl,ColToMarkup(Color(255, 90, 35)))
			end

			-- greentext doesnt work, due to how markupobjects are parsed
			--[[if v:sub(3, 3):find(">") and hnchat_greentext:GetBool() then
				table.insert(tbl,ColToMarkup(Color(46,231,46)))
			end]]

			table.insert(tbl,v)
		elseif isentity(v) then
			if v:IsPlayer() then
				table.insert(tbl,ColToMarkup(team.GetColor(v:Team())))

				table.insert(tbl,v:Nick())
			else
				local name = (v.Name and isfunction(v.name) and v:Name()) or v.Name or v.PrintName or tostring(v)
				if v:EntIndex() == 0 then
					table.insert(tbl,ColToMarkup(Color(106, 90, 205)))
					name = "Console"
				end

				table.insert(tbl,name)
			end
		else
			table.insert(tbl,tostring(v))
		end
	end

    chathud.AddMessage(table.concat(tbl))
end

hook.Add("HUDShouldDraw", "chathud", function(elem)

	if elem == "CHudChat" then 
		if hnchat_legacy:GetBool() then return end
		if not GetConVar"chathud_enable":GetBool() then return end

		return false
	end
end)

hook.Add("ChatText", "chathud", function(_,_,text,msg)
    if msg ~= "joinleave" or msg ~= "servermsg" then
        chathud.AddText(text)
    end
end)

hook.Add("HUDPaint","chathud",function()
    if hnchat_legacy:GetBool() then return end
    if not GetConVar"chathud_enable":GetBool() then return end

	local x = (pace and pace.IsActive() and pace.Editor:GetAlpha() ~= 0) and pace.Editor:GetWide() + 30 or 30
    local y = ScrH()*GetConVar"chathud_height":GetFloat()

	local offset = {}
	local i = #chathud.msgs
	local yoff = 0

	while i ~= 0 do
		offset[i] = yoff
		if chathud.msgs[i] then
			yoff = yoff - chathud.msgs[i].msg.totalHeight
		end
		i = i - 1
	end
	for _,m in next,chathud.msgs do
		m.yoffset = offset[_]
	end

    for n,m in next,chathud.msgs do
		local yoffset = offset[n]
        m.msg:Draw( x, y + yoffset, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM, m.alpha )
        if CurTime() > m.decay then
            m.alpha = Lerp(0.05,m.alpha,0)
            if math.Round(m.alpha) == 0 then
                table.remove(chathud.msgs,n)
            end
        end
    end
end)