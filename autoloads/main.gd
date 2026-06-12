extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawnpoints: Node2D = $Spawnpoints


func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_instance = player_scene
		players.add_child(player_instance, true)
		var spawn_point = spawnpoints.get_child(i) #OJO -> i <= Spawnpoints (Marker2D)
		player_instance.global_position = spawn_point.global_position
		player_instance.setup(player_data)
