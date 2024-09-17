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
		var papa = randi() % Game.players.size()
		for i in Game.players.size():
			var player_data = Game.players[i]
			var player_inst = player_scene.instantiate()
			players.add_child(player_inst)
			player_inst.setup(player_data,i,self)
			#if i == papa:
			#	print("hola")
			#	player_inst.has_potato = true
			#	rpc("sync_potato",i,true)
			player_inst.global_position = markers.get_child(i).global_position
		assign_potato(papa)	
		
func assign_potato(size: int) -> void:
	if Game.players.size()>0:
		if !papas[0] and !papas[1]:
		#if is_multiplayer_authority():
			#papas[size] = true
			rpc("sync_potato",size,true)
			print(size)
			var random_player = players.get_child(size)
			random_player.set_potato_state(true)

@rpc("any_peer","reliable")
func swap_potato(_pos: int,id_:int) -> void:
	Debug.log("hola")
	rpc_id(id_,"set_potato_state",false)
	
		
	
@rpc("any_peer","reliable")
func sync_potato(index:int,state:bool) -> void:
	if is_multiplayer_authority():
		Debug.log("si pase")
		#papas[index] = state
		var random_player = players.get_child(index)
		random_player.set_potato_state(true)
				
		
