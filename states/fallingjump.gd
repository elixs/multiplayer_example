extends State
class_name FallingJump

@export var fall_animation: AnimationPlayer
@export var sprite: Sprite2D
@export var idle_state: State
@export var jump_state: State
@export var falling_state: State

var SPEED = 300.0
var ACCELERATION = 1000.0

func enter():
	fall_animation.play("jumpFall")
	parent.rpc("send_animation","jumpFall")

func update(event:InputEvent) -> State:
	if event != null:	
		if event.is_action_pressed("jump") and jumps<2:
			return jump_state	
		if event.is_action_pressed("crouch"):
			return falling_state	
	return null	
func autoUpdate() -> State:
	if parent.is_on_floor():
		jumps = 0
		return idle_state
	return null	
func Physics_update(delta:float) -> void:
	var move_input = Input.get_axis("move_left","move_right")
	parent.velocity.x = move_toward(parent.velocity.x, SPEED* move_input, ACCELERATION * delta)
	if move_input>0:
		sprite.scale.x = 1.5
	if move_input<0:
		sprite.scale.x = -1.5	
	if not parent.is_on_floor():
			parent.velocity.y += gravity * delta
				
