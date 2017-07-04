hnchat = hnchat or {}

hnchat.net = {}
	util.AddNetworkString("hnchat_local")
	hnchat.net.local_send_sv = function( len, ply )
		local plys = net.ReadTable()
		local txt = net.ReadString()

		gamemode.Call( "PlayerSay", ply, txt, false)

		net.Start( "hnchat_local", false )
			net.WriteEntity(ply)
			net.WriteString(txt)
		net.Send(plys)
	end
	net.Receive( "hnchat_local", hnchat.net.local_send_sv )

	util.AddNetworkString("hnchat_say")
	hnchat.net.say_sv = function( len, ply )
		local txt = net.ReadString()
		local team = net.ReadBool()
		gamemode.Call( "PlayerSay", ply, txt, team )
	end
	net.Receive( "hnchat_say", hnchat.net.say_sv )