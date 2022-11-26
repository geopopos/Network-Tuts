extends KinematicBody2D

const MAXSPEED = 80
const ACCELERATION = 300

var motion = Vector2.ZERO
var possible_players
var target_player

onready var players = get_tree().get_root().find_node("Players", true, false)
onready var world = get_tree().get_root().get_node("World")

func _ready():
	possible_players = players.get_children()
	target_player = possible_players[0]
	rpc_id(1, "select_target")
	
remote func select_player_target(idx):
	target_player = possible_players[idx]
	
	
func _physics_process(delta):
	var player_direction = position.direction_to(target_player.position)
	motion = motion.move_toward(player_direction * MAXSPEED, ACCELERATION * delta)
	motion = move_and_slide(motion)
