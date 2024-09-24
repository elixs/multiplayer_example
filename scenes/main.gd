extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers


var player
@export var papas = [false,false]
# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000

func _ready() -> void:
	if Game.players.size()>0:
		for i in Game.players.size():
			var player_data = Game.players[i]
			var player_inst = player_scene.instantiate()
			player_data.scene = player_inst
			players.add_child(player_inst)
			player_inst.setup(player_data,i,self)
			player_inst.global_position = markers.get_child(i).global_position
		if multiplayer.is_server():
			await get_tree().create_timer(1).timeout
			var papa = randi() % Game.players.size()
			assign_potato.rpc(1)

@rpc("call_local", "reliable")
func assign_potato(papa: int) -> void:
	if papa < players.get_child_count():
		var player = players.get_child(papa)
		player.set_potato_state(true)


@rpc("any_peer","reliable")
func swap_potato(_pos: int,id_:int) -> void:
	rpc_id(id_,"set_potato_state",false)
