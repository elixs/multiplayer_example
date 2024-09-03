extends State
class_name Stunned

@export var moving_state:State

# Called when the node enters the scene tree for the first time.
func enter() -> void:
	parent.velocity.x = 0

func update(event: InputEvent) -> State:
	if event.is_action_pressed("lanzar"):
		return moving_state
	return null	
	
