
class_name Idle
extends State

@export var moving_state:State
@export var jump_state: State
@export var crouch_state: State
@export var idle_animation: AnimationPlayer
@export var state_machine: Node
var SPEED = 300.0
var ACCELERATION = 1000.0



func enter():
	idle_animation.play("idle")
	parent.rpc("send_animation","idle")
	if parent.velocity.x != 0:
		state_machine.change_state(state_machine.current_state,moving_state)
# Called when the node enters the scene tree for the first time.
func update(event: InputEvent) -> State:
	if event != null:
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
	var move_input = Input.get_axis("move_left","move_right")
	parent.velocity.x = move_toward(parent.velocity.x, SPEED* move_input, ACCELERATION * delta)
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
	else:
		jumps = 0	
	
