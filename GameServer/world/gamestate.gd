extends Node2D

const PLAYER = preload("res://player/player.tscn")

onready var players = $Players
onready var server = get_tree().current_scene

remote func spawn_players(id):
	var player = PLAYER.instance()
	player.name = str(id)
	players.add_child(player)
	var lobby_id = server.player_lobby[id]
	for p_id in server.lobbies[lobby_id]["players"]:
		rpc_id(p_id, "spawn_player", id)
