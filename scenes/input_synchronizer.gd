class_name InputSyncronizer
extends MultiplayerSynchronizer

@export var move_input: Vector2
@export var flight_input: bool
@export var mode_input: bool = true

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	move_input = Input.get_vector("input_left", "input_right", "input_up", "input_down")
	flight_input = Input.is_action_pressed("input_space")
	
	#if Input.is_action_just_pressed("input_movement_mode"):
	#	mode_input = !mode_input
