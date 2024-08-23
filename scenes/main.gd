extends Node2D

@export var player_scene: PackedScene

func _ready() -> void:
	for player_data in Game.players:
		var player_inst = player_scene.instantiate()
		player_inst.setpu(player_data)
		
