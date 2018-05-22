if SERVER then
	AddCSLuaFile("hnchat/hnchat_cl.lua")
	AddCSLuaFile("hnchat/easylua.lua")
	easylua = easylua or include("hnchat/easylua.lua")

	local files, dirs = file.Find( "hnchat/base/*", "LUA" )
	for k, v in next, files do
		AddCSLuaFile( "hnchat/base/" .. v )
		include( "hnchat/base/" .. v )
	end

	local files, dirs = file.Find( "hnchat/modules/*", "LUA" )
	for k, v in next, files do
		AddCSLuaFile( "hnchat/modules/" .. v )
		include( "hnchat/modules/" .. v )
	end

	local files, dirs = file.Find( "hnchathud/*", "LUA" )
	for k, v in next, files do
		AddCSLuaFile( "hnchathud/" .. v )
	end
else
	hook.Add("Initialize", "hnchat", function()
		easylua = easylua or include("hnchat/easylua.lua")
		include("hnchat/hnchat_cl.lua")
		include("hnchathud/chud.lua")
	end)
end
