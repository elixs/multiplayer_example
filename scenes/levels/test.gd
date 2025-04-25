extends Node2D

@export var player_scene: PackedScene
@onready var players_node: Node2D = $Players
@export var enemy_scene: PackedScene
@onready var enemies_node: Node2D = $Enemies

@onready var spawns: Node2D = $Spawns

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#for i in Game.players.size():
		#var player = Game.players[i]
		#var player_inst = player_scene.instantiate()
		#players_node.add_child(player_inst)
		#player_inst.setup(player)
		#player_inst.global_position = spawns.get_child(i).global_position
	#var enemy_inst = enemy_scene.instantiate()
	#enemies_node.add_child(enemy_inst)
	#
