extends Area3D

@export var speed = 20
@export var damage = 1
@export var direction = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#var dir = get_tree().get_first_node_in_group("player").global_transform_basis.z.normalized()
	global_position += speed * delta * direction


func _set_direction(dir: Vector3):
	direction = dir

# a futuro para colision
func _on_body_entered(body: Node3D) -> void:
	pass # Replace with function body.
