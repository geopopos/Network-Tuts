extends Node

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
		current_lobby_id += 1
		lobbies[current_lobby_id] = lobby_template
		rpc("start_game")
		var world = preload("res://world/world.tscn").instance()
		get_tree().get_root().add_child(world)
