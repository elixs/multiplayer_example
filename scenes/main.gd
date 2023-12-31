extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players


func _ready() -> void:
	for player_data in Game.players:
		var player = player_scene.instantiate()
		players.add_child(player)
		player.setup(player_data)
