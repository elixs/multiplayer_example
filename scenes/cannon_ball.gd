extends Area3D

@export var speed = 20
@export var damage = 1
@export var direction = Vector3()

var vertical_speed = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	vertical_speed -= gravity * delta

	global_position += (speed * delta * direction) + Vector3(0, vertical_speed * delta, 0)


func _set_direction(dir: Vector3):
	direction = dir

# a futuro para colision
func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
