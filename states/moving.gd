extends State
class_name Moving
var SPEED = 300.0
var ACCELERATION = 1000.0

@export var idle_state: State
@export var jump_state: State
@export var crouch_state: State
@export var moving_animation: AnimationPlayer

func enter() -> void:
	moving_animation.play("walking")
	parent.rpc("send_animation","walking")
# Called when the node enters the scene tree for the first time.
func update(event: InputEvent) -> State:
	if event.is_action_pressed("crouch"):
		return crouch_state
	if event.is_action_pressed("jump") and jumps<2:
		return jump_state
	return null	
	
func Physics_update(delta:float) -> void:
	var move_input = Input.get_axis("move_left","move_right")
	parent.velocity.x = move_toward(parent.velocity.x, SPEED* move_input, ACCELERATION * delta)
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
	else:
		jumps = 0	
		
			
