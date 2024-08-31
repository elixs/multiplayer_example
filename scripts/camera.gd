extends Camera3D

@export var sensitivity = 0.2 # Sensibilidad del mouse
@export var vertical_limit = 85.0 # Límite de rotación vertical (para evitar voltear la cámara)
var rotation_x = 0.0
var rotation_y = 0.0

func _ready():
	# Ocultar el cursor y capturar el mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Detectar movimiento del mouse
	if event is InputEventMouseMotion:
		# Actualizar la rotación horizontal y vertical con la sensibilidad
		rotation_x -= event.relative.y * sensitivity
		rotation_y -= event.relative.x * sensitivity

		# Limitar la rotación vertical para evitar que la cámara dé vueltas completas
		rotation_x = clamp(rotation_x, -vertical_limit, vertical_limit)

		# Aplicar las rotaciones a la cámara
		rotation_degrees.x = rotation_x
		rotation_degrees.y = rotation_y

func _unhandled_input(event):
	# Liberar el mouse al presionar ESC para salir del modo de captura
	if  Input.is_key_pressed(KEY_ESCAPE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
