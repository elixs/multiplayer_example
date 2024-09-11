extends State
class_name ForceDown

@export var idle_state: State
@export var moving_state: State
@export var forceDown_animation: AnimationPlayer

func enter() -> void:
	parent.velocity.x = 0
	forceDown_animation.play("forceDown")
	parent.rpc("send_animation","forceDown")

func update(event: InputEvent) -> State:
	if parent.is_on_floor() and (event.is_action_pressed("move_left") or event.is_action_pressed("move_right")): 
		return moving_state
	return null	

func autoUpdate() -> State:
	if parent.is_on_floor():
		return idle_state
	return null	
func Physics_update(delta:float) -> void:
	parent.velocity.y = 600
