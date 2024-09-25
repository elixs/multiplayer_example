extends RigidBody2D

@export var id: int
# Define la gravedad
var gravity = 1000

@export var speed = 0
@export var initial_vertical_velocity: float = -200.0
var velocity: Vector2

func _ready() -> void:
	# set_multiplayer_authority(id)
	# Initialize velocity for horizontal and vertical motion
	# velocity.x = speed
	velocity.y = initial_vertical_velocity

func setup_(speed_: int) -> void:
	velocity.x = speed_

func _physics_process(delta: float) -> void:
	# Aplica gravedad a la velocidad vertical
	velocity.y += gravity * delta
	
	# Actualiza la velocidad del RigidBody2D
	linear_velocity = velocity
	# Actualiza la posición del Area2D hijo
	for child in get_children():
		if child is Area2D:
			child.position = position  # Sincroniza la posición con el Area2D
