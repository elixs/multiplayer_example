class_name Throwable
extends RigidBody2D
	
# Action state of the current body
enum State {
	IDLE_STATE,
	MOVING_STATE,
	DRAG_STATE,
}
# initial and current state
var state: State = State.IDLE_STATE	
# The throw power
var throw_power: float = 5

# process to reset the state to idle when |velocity| = 0
func _physics_process(_delta: float) -> void:
	if linear_velocity == Vector2(0, 0) and state == State.MOVING_STATE:
		state = State.IDLE_STATE
