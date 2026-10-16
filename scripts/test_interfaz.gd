extends Control

# Escena de prueba de la interfaz. Levanta el HUD, la tienda y el cierre de jornada sin
# necesidad de hostear ni unirse a una partida. El día lo lleva la Jornada de verdad, lo
# único falso acá es que el reloj corre más rápido para no quedarse esperando.

## Con cuánta plata parte la prueba. Alcanza para comprar la receta más cara.
const DINERO_INICIAL: int = 250

# El reloj avanza de a varios segundos por latido para ver la aguja moverse y llegar
# pronto al cierre del día.
const SEGUNDOS_POR_LATIDO: int = 2
const DURACION_DEL_LATIDO: float = 0.3

var _gestor: GameManager
var _hud: Control
var _tienda: Tienda
var _cierre: CierreDeDia


func _ready() -> void:
	# El GameManager y la Jornada son autoloads, así que ya existen y son los mismos que
	# usa el juego. Al gestor se le apaga su reloj propio para manejarlo desde acá.
	_gestor = GameManager.instance
	for hijo: Node in _gestor.get_children():
		if hijo is Timer:
			(hijo as Timer).stop()

	_tienda = load("res://ui/tienda/tienda.tscn").instantiate()
	_cierre = load("res://ui/cierre/cierre_de_dia.tscn").instantiate()
	_hud = load("res://hud/hud.tscn").instantiate()
	_hud.tienda = _tienda
	_hud.cierre = _cierre
	add_child(_hud)
	add_child(_tienda)
	add_child(_cierre)

	var latido: Timer = Timer.new()
	latido.wait_time = DURACION_DEL_LATIDO
	latido.autostart = true
	latido.timeout.connect(_avanzar_el_reloj)
	add_child(latido)

	# La compra pasa por el Recetario igual que en el juego, así que acá solo hace falta
	# darle plata a la panadería para poder probarla.
	_gestor.añadir_dinero(DINERO_INICIAL)
	_avisar_tiempo(Jornada.instance.duracion_del_dia)


func _avanzar_el_reloj() -> void:
	if _gestor.game_time <= 0:
		return
	_avisar_tiempo(maxi(_gestor.game_time - SEGUNDOS_POR_LATIDO, 0))


func _avisar_tiempo(segundos: int) -> void:
	_gestor.game_time = segundos
	_gestor.timer_updated.emit(segundos)
