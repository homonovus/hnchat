if SERVER then
	AddCSLuaFile("hnchat/hnchat_cl.lua")
	include("hnchat/hnchat_sv.lua")

	local files, dirs = file.Find( "addons/hnchat/lua/hnchat/modules/*", "GAME" )
	for k, v in next, files do
		AddCSLuaFile( "addons/hnchat/lua/hnchat/modules/" .. v )
	end
else
	include("hnchat/hnchat_cl.lua")
end