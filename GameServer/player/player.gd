extends Node2D

onready var server = get_tree().current_scene

remote func update_player(id, transform):
	var lobby_id = server.player_lobby[id]
	for p_id in server.lobbies[lobby_id]["players"]:
		rpc_unreliable_id(p_id, "update_remote_player", transform)
