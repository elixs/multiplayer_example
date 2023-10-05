extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn


func _ready() -> void:
	Game.players.sort_custom(func (a, b): return a.id < b.id)
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player = player_scene.instantiate()
		players.add_child(player)
		player.setup(player_data)
		if player_data.role == 1:
			player.global_position = spawn.get_child(0).global_position
		elif player_data.role == 2:
			player.global_position = spawn.get_child(1).global_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
