
class_name Idle
extends State

@export var moving_state:State
@export var jump_state: State
@export var crouch_state: State



func enter():
	pass
# Called when the node enters the scene tree for the first time.
func update(event: InputEvent) -> State:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		return moving_state
		#Transicion
	if event.is_action_pressed("jump") and jumps<2:
		return jump_state
	if event.is_action_pressed("crouch"):
		return crouch_state	
	return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_update(delta):
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
	else:
		jumps = 0	
	
