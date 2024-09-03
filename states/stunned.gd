extends State
class_name Stunned

@export var moving_state:State
@export var state_machine: Node

# Called when the node enters the scene tree for the first time.
func enter() -> void:
	parent.velocity.x = 0

func update(event: InputEvent) -> State:
	if !state_machine.is_frozen:
		return moving_state
	return null	
	
