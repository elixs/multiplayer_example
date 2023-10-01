class_name Player
extends CharacterBody2D

@export var speed = 400
@onready var pause_menu = $CanvasLayer/Pause_Menu

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
		
#		if Input.is_action_pressed("right_click"):
#			var mousePos = get_global_mouse_position()
#			var space = get_world_2d().direct_space_state
#			var collision_objects = space.intersect_point(mousePos, 1)
#			if collision_objects:
#				if collision_objects is Cliente:
#					Debug.dprint(collision_objects[0].collider.name)
#			else:
#				Debug.dprint("no hit")
		
func setup(player_data: Game.PlayerData):
	set_multiplayer_authority(player_data.id)
	name = str(player_data.id)
	#Debug.dprint(player_data.name, 30)
	#Debug.dprint(player_data.role, 30)
	pause_menu.set_multiplayer_authority(player_data.id)

	
@rpc
func test():
#	if is_multiplayer_authority():
	Debug.dprint("test - player: %s" % name, 30)
