extends Area2D

@onready var timer: Timer = $Timer
@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
func _on_body_entered(body):
	print("body entered")
	if body.is_in_group("throwable"):
		print(" is throwable")
		throw(body)
	else:
		print("not throwable")

func throw(target):
	# Oculta el personaje
	target.visible = false
	
	# Detiene la animación de rotación
	animator.stop(true)
	var launch_direction = global_transform.y.normalized()
	var force = 1000  # Ajusta la fuerza según necesites
	# Espera 1 segundo
	timer.start(1.0)

	await timer.timeout
	# Lanza al personaje
	if target.has_method("apply_central_impulse"):
		target.apply_central_impulse(launch_direction * force)
	elif target.has_method("set_linear_velocity"):
		target.set_linear_velocity(launch_direction * force)
	else:
		target.global_position += launch_direction * 100  # Fallback simple
	
	# Vuelve a hacerlo visible
	target.visible = true
	
	# Reanuda la animación de rotación
	animator.play("rotate")
