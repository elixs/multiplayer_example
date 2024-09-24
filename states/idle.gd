
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
	parent.change_collision_shape(RectangleShape2D.new(),1.5,1.5,6)
	parent.rpc("send_collision_shape",RectangleShape2D.new(),1.5,1.5,6)
# Called when the node enters the scene tree for the first time.
func update(event: InputEvent) -> State:
	if event != null:
		if event.is_action_pressed("move_right"):
			return moving_state
		if event.is_action_pressed("move_left"):
			return moving_state
		if event.is_action_pressed("jump") and parent.jumps<2:
			return jump_state
		if event.is_action_pressed("crouch"):
			return crouch_state	
	return null

func autoUpdate() -> State:
	if Input.is_action_pressed("move_left") and Input.is_action_pressed("move_right"):
		return null
	if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		return moving_state
	return null		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func Physics_update(delta):
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
	else:
		parent.jumps = 0	
	
