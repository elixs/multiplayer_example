extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers

var SPEED = 300.0
var JUMP_VELOCITY = 400.0
var ACCELERATION = 1000
var jumps = 0
var is_frozen: bool = false
var player
# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000

func _ready() -> void:
	for i in Game.players.size():
		print(Game.players.size())
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position = markers.get_child(i).global_position
		
