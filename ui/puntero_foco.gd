class_name PunteroFoco
extends TextureRect

# Patita que marca el control enfocado, para que se note dónde está parado el teclado o
# el mando sin pintar un contorno encima del botón.
#
# Se engancha al cambio de foco del viewport, así que no necesita saber qué botones hay
# en la pantalla: basta con ponerlo como hijo suelto de la raíz y queda funcionando.

enum Lado {
	DENTRO_DERECHA,
	FUERA_IZQUIERDA,
}

## Dentro del botón sirve cuando detrás hay una ilustración y la patita necesita el
## relleno del botón para leerse. Fuera sirve cuando el fondo es liso.
@export var lado: Lado = Lado.DENTRO_DERECHA
## Separación entre la patita y el borde del botón.
@export var margen: float = 22.0
## Los campos de texto ya avisan por su cuenta que tienen el foco, así que no se marcan.
@export var solo_botones: bool = true

const DURACION: float = 0.12

var _objetivo: Control
var _tween: Tween


func _ready() -> void:
	hide()
	set_process(false)
	get_viewport().gui_focus_changed.connect(_seguir_a)


func _process(_delta: float) -> void:
	# Los contenedores recolocan sus botones al cambiar el tamaño de la ventana, así que
	# la patita recalcula su lugar mientras no esté animándose.
	if _objetivo and not (_tween and _tween.is_running()):
		global_position = _posicion_junto_a(_objetivo)


func _seguir_a(control: Control) -> void:
	if control == null or (solo_botones and control is not BaseButton):
		_objetivo = null
		set_process(false)
		hide()
		return

	var destino: Vector2 = _posicion_junto_a(control)
	var primera_vez: bool = not visible
	_objetivo = control
	set_process(true)
	show()

	if _tween and _tween.is_running():
		_tween.kill()
	if primera_vez:
		global_position = destino
		return
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "global_position", destino, DURACION)


func _posicion_junto_a(control: Control) -> Vector2:
	var centro_vertical: float = control.global_position.y + (control.size.y - size.y) * 0.5
	if lado == Lado.FUERA_IZQUIERDA:
		return Vector2(control.global_position.x - size.x - margen, centro_vertical)
	return Vector2(control.global_position.x + control.size.x - size.x - margen, centro_vertical)
