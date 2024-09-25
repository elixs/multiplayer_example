extends RigidBody2D

var id: int = 0

@export var gravity: float = 1000
@export var initial_vertical_velocity: float = -200.0
var velocity: Vector2

func _ready() -> void:
	# Inicializa la velocidad vertical
	velocity.y = initial_vertical_velocity
	add_to_group("potato")

func setup_(speed_: int) -> void:
	velocity.x = speed_

func _physics_process(delta: float) -> void:
	# Aplica gravedad a la velocidad vertical
	velocity.y += gravity * delta
	linear_velocity = velocity  # Usa linear_velocity para aplicar movimiento
	
