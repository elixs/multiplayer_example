class_name DragArea
extends Area2D

@export var drag_radius: float = 100
@export var throw_power: float = 5
@onready var segments: int = 32
@onready var shape_area: CollisionShape2D = $ShapeArea
@onready var circle: Line2D = $Circle

# Function to check the drag on the area
func input_action(event: InputEvent, body: Throwable):
	if body.state == body.State.IDLE_STATE:
		if event.is_action_pressed("click"):
			if event.is_pressed() and _mouse_over(body):
				Debug.log("Neee")
				body.state = body.State.DRAG_STATE
	elif body.state == body.State.DRAG_STATE:
		_draw_circle()
		if event.is_action_released("click"):
			Debug.log("Wuuuu")
			_clear_circle()
			_throw(body)
			
# Function to check if the mouse is over the drag area
# return true if is over, false otherwise
func _mouse_over(body: Throwable) -> bool:
	return get_global_mouse_position().distance_to(body.position) <= shape_area.shape.radius

# Function to execute the throw of the body
func _throw(body: Throwable) -> void:
	body.state = body.State.MOVING_STATE
	# Direction and distance of the mouse position and body position
	var dir: Vector2 = (get_global_mouse_position() - body.position).normalized()
	var dist: float = get_global_mouse_position().distance_to(body.position)
	# if the mouse position is farest than area set the max radious
	if dist >= drag_radius:
		dist = drag_radius
	# calculate the impulse by the normalized vector and distance
	var impulse: Vector2 = dir * -dist * throw_power
	body.apply_central_impulse(impulse)

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
