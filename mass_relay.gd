extends Area2D

@onready var timer: Timer = $Timer
@onready var animator: AnimationPlayer = $AnimationPlayer
var is_throwing = false
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
func _on_body_entered(body):
	if body.is_in_group("throwable") and not is_throwing:
		is_throwing = true
		throw(body)

func throw(target):
	animator.pause()
	 	target.linear_velocity = Vector2.ZERO  # Detiene movimiento si tiene

	# Reubica el objeto al centro del Mass Relay
	print("Antes de mover: ", target.global_position)
	target.call_deferred("set_global_position", global_position)
	#print("Intentando mover a: ", global_position)

	#await get_tree().process_frame  # Espera al siguiente frame para ver si se "revierte"
	#print("Después de mover (1 frame): ", target.global_position)

	var launch_direction = -global_transform.y.normalized()
	var force = 100000
	timer.start(0.3)
	await timer.timeout
	if target.has_method("apply_central_impulse"):
		target.apply_central_impulse(launch_direction * force)
	elif target.has_method("set_linear_velocity"):
		target.set_linear_velocity(launch_direction * force)
	else:
		target.global_position += launch_direction * 100
	timer.start(0.3)
	await timer.timeout

	animator.play("rotate")
	is_throwing = false
	
