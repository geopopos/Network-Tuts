extends Node

const PLAYER = preload("res://player/player.tscn")

var network = NetworkedMultiplayerENet.new()
var port = 3234
var max_players = 4

var current_lobby_id = 0
var player_lobby = {}
var lobbies = {
	0: {
		"players": {},
		"ready_players": 0
	}
}
var lobby_template = {
		"players": {},
		"ready_players": 0
	}
#var players = {}
#var ready_players = 0

func _ready():
	start_server()
	
func start_server():
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	network.connect("peer_connected", self, "_player_connected")
	network.connect("peer_disconnected", self, "_player_disconnected")
	
	print("Server Started")
	
func _player_connected(player_id):
	print("Player " + str(player_id) + " Connected")
	rpc_id(player_id, "set_lobby_id", current_lobby_id)
	
func _player_disconnected(player_id):
	print("Player " + str(player_id) + " Disconnected")
	
remote func send_player_info(id, player_data):
	lobbies[current_lobby_id]["players"][id] = player_data
	player_lobby[id] = current_lobby_id
	rset("players", lobbies[current_lobby_id]["players"])
	rpc("update_waiting_room")

remote func load_world(id):
	var lobby_id = player_lobby[id]
	lobbies[lobby_id]["ready_players"] += 1
	if lobbies[lobby_id]["players"].size() > 1 and lobbies[lobby_id]["ready_players"] >= lobbies[lobby_id]["players"].size():
		for p_id in lobbies[lobby_id]["players"]:
			rpc_id(p_id, "start_game")
		var world = preload("res://world/world.tscn").instance()
		lobbies[lobby_id]["world"] = world
		world.name = "World" + str(lobby_id)
		for p_id in lobbies[lobby_id]["players"]:
			print(world.name)
			rpc_id(p_id, "set_world_name", world.name)
		get_tree().get_root().add_child(world)
		current_lobby_id += 1
		lobbies[current_lobby_id] = lobby_template

remote func spawn_players(id):
	print("spawn_players")
	var player = PLAYER.instance()
	player.name = str(id)
	var lobby_id = player_lobby[id]
	var world = lobbies[lobby_id]["world"]
	print("lobby id: " + str(lobby_id))
	print("World Name: " + world.name)
	world.get_node("Players").add_child(player)
	world.spawn_players(id, lobby_id)
	
remote func spawn_enemies(id):
	var lobby_id = player_lobby[id]
	var world = lobbies[lobby_id]["world"]
	world.spawn_enemies(id)
