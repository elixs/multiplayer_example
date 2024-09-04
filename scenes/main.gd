extends Node2D

@export var player_scene : PackedScene
@onready var Players = $Players
@onready var markers = $Markers

func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		Players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position = markers.get_child(i).global_position
		
