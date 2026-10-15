class_name ClienteNPC
extends CharacterBody3D

enum Estado { CAMINANDO_A_FILA, ESPERANDO, SALIENDO }
var estado_actual: Estado = Estado.CAMINANDO_A_FILA

signal cliente_se_fue(cliente)

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var velocidad: float = 2.0
var punto_salida: Vector3

func _physics_process(delta: float) -> void:
	match estado_actual:
		Estado.CAMINANDO_A_FILA, Estado.SALIENDO:
			_caminar_hacia_destino(delta)
		Estado.ESPERANDO:
			velocity = Vector3.ZERO
			# Aquí puedes hacer que mire hacia el mostrador/jugador
			
func _caminar_hacia_destino(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		if estado_actual == Estado.CAMINANDO_A_FILA:
			estado_actual = Estado.ESPERANDO
		elif estado_actual == Estado.SALIENDO:
			cliente_se_fue.emit(self)
			queue_free() # Se elimina cuando llega a la salida
		return

	var destino_siguiente = nav_agent.get_next_path_position()
	var direccion = global_position.direction_to(destino_siguiente)
	
	# Girar el modelo hacia donde camina
	var look_dir = Vector2(direccion.z, direccion.x)
	rotation.y = lerp_angle(rotation.y, look_dir.angle(), 10 * delta)

	velocity = direccion * velocidad
	move_and_slide()
