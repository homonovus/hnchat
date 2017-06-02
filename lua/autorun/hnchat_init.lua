if SERVER then
	AddCSLuaFile("hnchat/hnchat_cl.lua")
	include("hnchat/hnchat_sv.lua")
else
	include("hnchat/hnchat_cl.lua")
end