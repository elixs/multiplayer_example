class_name Player
extends CharacterBody2D

@export var speed = 400

var target = position

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event.is_action_pressed("test"):
			test.rpc_id(1)
			
func _physics_process(delta):
	if is_multiplayer_authority():
		if Input.is_action_pressed("left_click"):
			target = get_global_mouse_position() 
			velocity = position.direction_to(target) * speed
		if position.distance_to(target) > 10:
			move_and_slide()
		
func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	Debug.dprint(player_data.name, 30)
	Debug.dprint(player_data.role, 30)


#func _input(event: InputEvent) -> void:
#	if is_multiplayer_authority():
#		if event.is_action_pressed("test"):
#			test.rpc_id(1)

@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)
