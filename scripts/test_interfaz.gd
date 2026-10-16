extends Control

# Escena de prueba de la interfaz. Levanta el HUD y la tienda sin necesidad de hostear
# ni unirse a una partida, y hace correr una jornada falsa para que el reloj y el dinero
# se muevan. Sirve para revisar la interfaz sin montar toda la sesión en red.

## Cuánto dura la jornada de prueba, en segundos de juego.
const SEGUNDOS_DE_JORNADA: int = 180

## Con cuánta plata parte la prueba. Alcanza para comprar la receta más cara.
const DINERO_INICIAL: int = 250

# La jornada avanza más rápido que en el juego para poder ver la aguja moverse sin
# quedarse esperando.
const SEGUNDOS_POR_LATIDO: int = 2
const DURACION_DEL_LATIDO: float = 0.3

var _gestor: GameManager
var _hud: Control
var _tienda: Tienda
var _restante: int = SEGUNDOS_DE_JORNADA


func _ready() -> void:
	# El GameManager es un autoload, así que ya existe y es el mismo que usa el juego.
	_gestor = GameManager.instance
	# Trae su propio reloj corriendo. Acá se detiene para manejar la jornada desde esta
	# escena y poder verla pasar más rápido que en una partida.
	for hijo: Node in _gestor.get_children():
		if hijo is Timer:
			(hijo as Timer).stop()

	_tienda = load("res://ui/tienda/tienda.tscn").instantiate()
	_hud = load("res://hud/hud.tscn").instantiate()
	_hud.tienda = _tienda
	add_child(_hud)
	add_child(_tienda)

	var latido: Timer = Timer.new()
	latido.wait_time = DURACION_DEL_LATIDO
	latido.autostart = true
	latido.timeout.connect(_avanzar_la_jornada)
	add_child(latido)

	# La compra pasa por el Recetario igual que en el juego, así que acá solo hace falta
	# darle plata a la panadería para poder probarla.
	_gestor.añadir_dinero(DINERO_INICIAL)
	_avisar_tiempo()


func _avanzar_la_jornada() -> void:
	_restante = _restante - SEGUNDOS_POR_LATIDO
	if _restante <= 0:
		_restante = SEGUNDOS_DE_JORNADA
	_avisar_tiempo()


func _avisar_tiempo() -> void:
	_gestor.game_time = _restante
	_gestor.timer_updated.emit(_restante)
