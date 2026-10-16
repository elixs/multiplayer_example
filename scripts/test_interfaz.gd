extends Control

# Escena de prueba de la interfaz. Levanta el HUD, la tienda y el cierre de jornada sin
# necesidad de hostear ni unirse a una partida, y hace correr un día falso para que el
# reloj y el dinero se muevan. Sirve para revisar la interfaz sin montar la sesión en red.

## Cuánto dura la jornada de prueba, en segundos de juego.
const SEGUNDOS_DE_JORNADA: int = 180

## Con cuánta plata parte la prueba. Alcanza para comprar la receta más cara.
const DINERO_INICIAL: int = 250

## Cuánto hay que juntar para cumplir el día. Todavía no existe en el juego, así que acá
## es un número puesto a mano para poder ver la pantalla de cierre en sus dos estados.
const META_DEL_DIA: int = 300

# La jornada avanza más rápido que en el juego para poder ver la aguja moverse sin
# quedarse esperando.
const SEGUNDOS_POR_LATIDO: int = 2
const DURACION_DEL_LATIDO: float = 0.3

var _gestor: GameManager
var _hud: Control
var _tienda: Tienda
var _cierre: CierreDeDia
var _latido: Timer
var _restante: int = SEGUNDOS_DE_JORNADA
var _dia: int = 1


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
	_cierre = load("res://ui/cierre/cierre_de_dia.tscn").instantiate()
	_hud.tienda = _tienda
	add_child(_hud)
	add_child(_tienda)
	add_child(_cierre)
	_cierre.continuado.connect(_empezar_otro_dia)

	_latido = Timer.new()
	_latido.wait_time = DURACION_DEL_LATIDO
	_latido.autostart = true
	_latido.timeout.connect(_avanzar_la_jornada)
	add_child(_latido)

	# La compra pasa por el Recetario igual que en el juego, así que acá solo hace falta
	# darle plata a la panadería para poder probarla.
	_gestor.añadir_dinero(DINERO_INICIAL)
	_avisar_tiempo()


func _avanzar_la_jornada() -> void:
	_restante = _restante - SEGUNDOS_POR_LATIDO
	if _restante <= 0:
		_restante = 0
		_avisar_tiempo()
		_cerrar_la_jornada()
		return
	_avisar_tiempo()


# En el juego estos números los va a llevar quien cuente los clientes y las entregas.
# Acá los dos últimos son inventados, y el primero sí es el dinero de verdad.
func _cerrar_la_jornada() -> void:
	_latido.stop()
	_hud.hide()
	_cierre.mostrar(_dia, _gestor.dinero_recaudado, 12, 9, META_DEL_DIA)


func _empezar_otro_dia() -> void:
	_dia += 1
	_restante = SEGUNDOS_DE_JORNADA
	_hud.show()
	_avisar_tiempo()
	_latido.start()


func _avisar_tiempo() -> void:
	_gestor.game_time = _restante
	_gestor.timer_updated.emit(_restante)
