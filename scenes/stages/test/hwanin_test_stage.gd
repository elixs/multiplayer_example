extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/characters/base_character.tscn")
@onready var players: Node2D = $Players

func _ready() -> void:
	for player_data in Game.players:
		var instance = player_scene.instantiate()
		players.add_child(instance)
		instance.setup(player_data)
		
