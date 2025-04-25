extends CharacterBody2D

@export var max_speed = 300
@export var acceleration = 5000
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var label: Label = $Label
@onready var pivot: Node2D = $pivot
@onready var weapon_container = $WeaponContainer
@onready var weapon = $WeaponContainer/AbstractWeapon


@onready var camera_2d: Camera2D = $Camera2D

@onready var gravityArea = $GravityArea
@onready var area: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $pivot/Sprite2D

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	if is_multiplayer_authority():
			camera_2d.make_current()

var AttractedBy = []

func _physics_process(delta: float) -> void:
	
	for gravity in AttractedBy:
		if not is_on_floor():
			velocity += (gravity.get_global_position() - get_global_position()) * 0.4
		
	var initial_move_input=Vector2.ZERO
	if is_multiplayer_authority():
		initial_move_input = Input.get_axis("move_left", "move_right")
		var move_input = Vector2(initial_move_input,0).rotated(get_global_rotation())
		velocity= velocity.move_toward(move_input * max_speed, acceleration * delta)
		send_data.rpc(position, velocity)
		
		weapon_container.look_at(get_global_mouse_position())
		if Input.is_action_just_pressed('fire'):
			weapon.shoot.rpc()
	
	

	if not AttractedBy.is_empty():
		look_at(AttractedBy[0].get_global_position())
		rotate(-PI/2)
		#up_direction = Vector2.UP.rotated(get_global_rotation() - PI/2) 
		up_direction = -global_transform.y
	move_and_slide()
	
	if initial_move_input:
		playback.travel("walk")
		pivot.scale.x = sign(initial_move_input)
	else:
		playback.travel("idle")

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.3)
	velocity = vel

func _on_area_2d_area_entered(area: Area2D) -> void:
	AttractedBy.append(area)

func _on_area_2d_area_exited(area: Area2D) -> void:
	AttractedBy.erase(area)
