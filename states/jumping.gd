extends State
class_name Jumping

@export var idle_state: State
@export var moving_state: State
# Called when the node enters the scene tree for the first time.
var JUMP_VELOCITY = -400.0
var SPEED = 300.0
var ACCELERATION = 1000.0

func enter() -> void:
	parent.velocity.y = JUMP_VELOCITY
	jumps+=1

func exit() -> void:
	pass

func update(event: InputEvent) -> State:
	if event.is_action_pressed("jump"):
		if jumps<2:
			jumps+=1
			parent.velocity.y += JUMP_VELOCITY
	if(parent.is_on_floor()):
		jumps=0
		return moving_state	
	return null
		

func Physics_update(delta:float) -> void:
	var move_input = Input.get_axis("move_left","move_right")
	parent.velocity.x = move_toward(parent.velocity.x, SPEED* move_input, ACCELERATION * delta)
	if not parent.is_on_floor():
			parent.velocity.y += gravity * delta
