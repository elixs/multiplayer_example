extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/characters/base_character.tscn")
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers

func _ready() -> void:
	print(Game.players.size())
	for i in Game.players.size():
		var player_data = Game.players[i]
		var instance: BaseCharacter = player_scene.instantiate()
		players.add_child(instance)
		instance.setup(player_data)
		instance.global_position = markers.get_child(i).global_position
