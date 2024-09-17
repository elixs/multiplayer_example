extends Node2D

@export var player_scene: PackedScene
@onready var players: Node2D = $Players
@onready var markers: Node2D = $Markers


var player
@export var papas = [false,false]
# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000

func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data,i,self)
		player_inst.global_position = markers.get_child(i).global_position
	assign_potato()
	
func assign_potato() -> void:
	if is_multiplayer_authority():
		if players.get_child_count() > 0:
			var random_index = randi() % players.get_child_count() # Selecciona un índice aleatorio
			papas[random_index] = true
			var random_player = players.get_child(random_index)
			print(random_index)
			random_player.set_potato_state(true)
			rpc("sync_potato",random_index,true)

@rpc("any_peer","reliable")
func swap_potato(_pos: int) -> void:
	Debug.log("hola")
	var otro = 0
	papas[_pos] = !papas[_pos]
	if _pos == 0:
		otro = 1	
	papas[otro] = !papas[otro]
	rpc("sync_potato",_pos,true)
	rpc("sync_potato",otro,false)
		
	
@rpc("any_peer","reliable")
func sync_potato(index:int,state:bool) -> void:
	Debug.log("si pase")
	papas[index] = state
	var random_player = players.get_child(index)
	random_player.set_potato_state(state)
				
		
