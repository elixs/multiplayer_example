extends State
class_name Rolling

@export var idle_state: State
@export var jump_state: State
@export var falling_state: State
@export var rolling_animation: AnimationPlayer

var friction = 300

func enter() -> void:
	rolling_animation.play("rolling")
	parent.rpc("send_animation","rolling")
	parent.change_collision_shape(CircleShape2D.new(),1.5,1.5,10)
	parent.rpc("send_collision_shape",CircleShape2D.new(),1.5,1.5,10)

func update(event:InputEvent) -> State:
	if event != null:
		if event.is_action_released("move_left") or event.is_action_released("move_right"):
			return idle_state
		if event.is_action_pressed("jump"):
			return jump_state
		if not parent.is_on_floor() and event.is_action_pressed("fall"):
			return falling_state	
	return null	
	
func Physics_update(delta: float) -> void:
	if not parent.is_on_floor():
		parent.velocity.y += gravity * delta
