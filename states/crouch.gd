extends State

@export var moving_state: State
@export var idle_state: State


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	parent.update_sprite(20)
	
func update(event:InputEvent) -> State:
	if event.is_action_pressed("move_left") or event.is_action_pressed("move_right"):
		return moving_state	
	if event.is_action_released("crouch"):
		return idle_state	
	return null
	
func Physics_update(delta:float) -> void:
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta	
