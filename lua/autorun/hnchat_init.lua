if SERVER then
	AddCSLuaFile("hnchat/hnchat_cl.lua")
	include("hnchat/hnchat_sv.lua")

	local files, dirs = file.Find( "addons/hnchat/lua/hnchat/base/*", "GAME" )
	for k, v in next, files do
		AddCSLuaFile( "hnchat/base/" .. v )
		include( "hnchat/base/" .. v )
	end

	local files, dirs = file.Find( "addons/hnchat/lua/hnchat/modules/*", "GAME" )
	for k, v in next, files do
		AddCSLuaFile( "hnchat/modules/" .. v )
		include( "hnchat/modules/" .. v )
	end
else
	include("hnchat/hnchat_cl.lua")
end