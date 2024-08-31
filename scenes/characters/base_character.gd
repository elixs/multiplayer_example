class_name BaseCharacter
extends RigidBody2D

# Action state of the current character
enum State {
	IDLE_STATE,
	MOVING_STATE,
	DRAG_STATE,
}

# Character properties
var health: int = 100
var weapons: Array = Array([], TYPE_OBJECT, "", null)
var throw_power: float = 5
var state: State = State.IDLE_STATE

# Visual properties
@onready var shape_area: CollisionShape2D = $DragArea/ShapeArea
@onready var circle: Line2D = $Circle
var segments: int = 32
var drag_radius: float = 100

func _ready() -> void:
	pass

# Input management
func _input(event: InputEvent) -> void:
	if state == State.IDLE_STATE:
		if event.is_action_pressed("click"):
			if event.is_pressed() and _mouse_over():
				Debug.log("Neee")
				state = State.DRAG_STATE
	elif state == State.DRAG_STATE:
		_draw_circle()
		if event.is_action_released("click"):
			Debug.log("Wuuuu")
			_clear_circle()
			_throw()

func _physics_process(delta: float) -> void:
	if linear_velocity == Vector2(0, 0) and state == State.MOVING_STATE:
		state = State.IDLE_STATE

# Function to check if the mouse is over the drag area
# return true if is over, false otherwise
func _mouse_over() -> bool:
	return get_global_mouse_position().distance_to(position) <= drag_radius

# Function to execute the throw of the character
func _throw() -> void:
	state = State.MOVING_STATE
	# Direction and distance of the mouse position and character position
	var dir: Vector2 = (get_global_mouse_position() - position).normalized()
	var dist: float = get_global_mouse_position().distance_to(position)
	# if the mouse position is farest than area set the max radious
	if dist >= drag_radius:
		dist = drag_radius
	# calculate the impulse by the normalized vector and distance
	var impulse: Vector2 = dir * -dist * throw_power
	apply_central_impulse(impulse)

# Function to draw circle arround the drag area
func _draw_circle() -> void:
	# its magic
	var angle_step = TAU / segments
	for i in range(segments):
		var angle = i * angle_step
		var x = drag_radius * cos(angle)
		var y = drag_radius * sin(angle)
		circle.add_point(Vector2(x, y))

	circle.add_point(Vector2(drag_radius, 0))
	
func _clear_circle() -> void:
	circle.clear_points()
