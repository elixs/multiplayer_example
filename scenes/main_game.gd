extends Node2D

@export var player_scene: PackedScene

@onready var players: Node2D = $Players


func _ready() -> void:
	for player in Game.players:
		var player_inst = player_scene.instantiate()
		player_inst.setup(player)
		players.add.child(player_inst)
