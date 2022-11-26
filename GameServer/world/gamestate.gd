extends Node2D

const ENEMY = preload("res://enemy/enemy.tscn")

onready var players = $Players
onready var enemies = $Enemies
onready var server = get_tree().current_scene

var enemy_count = 0
var max_enemies = 5

func spawn_players(id, lobby_id):
	for p_id in server.lobbies[lobby_id]["players"]:
		rpc_id(p_id, "spawn_player", id)
	

func spawn_enemies(id):
	var enemy_instance = ENEMY.instance()
	var idx = randi() % 4
	enemy_instance.name = str(enemy_count)
	
	if enemy_count < max_enemies:
		enemy_count += 1
		enemies.add_child(enemy_instance)
		rpc("spawn_enemy", idx, enemy_instance.name)
