class_name Jornada
extends Node

# Lleva la cuenta del día de la panadería: en qué día va, cuánto se juntó, a cuántos
# clientes se atendió y cuántos panes salieron. Cuando el reloj llega a cero cierra el
# día y avisa, para que la interfaz muestre el resumen.
#
# No calcula nada del juego por su cuenta. Los demás sistemas le avisan lo que pasó con
# anotar_cliente_atendido y anotar_pan_entregado, y ella solo suma. Así llevar la cuenta
# no obliga a nadie a conocer la pantalla de cierre.
#
# El día lo cierra y lo arranca siempre el servidor, igual que la compra de recetas, para
# que todas las máquinas pasen de día al mismo tiempo y con los mismos números.

static var instance: Jornada

## Cuánto dura un día en segundos. Es un número de relleno hasta que el equipo decida
## la dificultad.
@export var duracion_del_dia: int = 120

## Cuántas monedas hay que juntar para cumplir el día. También es de relleno.
@export var meta_de_monedas: int = 300

## Se emite en todas las máquinas cuando termina el día, con las cifras ya calculadas.
signal dia_terminado(numero_de_dia: int, monedas: int, clientes: int, panes: int, perdidos: int, meta: int)

## Se emite cada vez que cambia lo juntado, para que el HUD mueva su barra de meta.
signal avance_cambiado(monedas: int, meta: int)

var numero_de_dia: int = 1

# La caja del GameManager es acumulada, así que lo del día sale de restar con cuánto se
# empezó. Si alguien compra una receta, esa plata también se descuenta del día.
var _caja_al_empezar: int = 0
var _clientes_atendidos: int = 0
var _panes_entregados: int = 0
var _clientes_perdidos: int = 0
var _dia_cerrado: bool = false


func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	if GameManager.instance:
		_conectar_game_manager()
	else:
		await get_tree().process_frame
		if GameManager.instance:
			_conectar_game_manager()


## Cuántas monedas lleva juntadas el día, descontando lo que se haya gastado.
func monedas_del_dia() -> int:
	if GameManager.instance == null:
		return 0
	return GameManager.instance.dinero_recaudado - _caja_al_empezar


func clientes_atendidos() -> int:
	return _clientes_atendidos


func panes_entregados() -> int:
	return _panes_entregados


## Cuántos clientes se fueron sin que los atendieran.
func clientes_perdidos() -> int:
	return _clientes_perdidos


## Lo llama quien atienda a un cliente. Cualquiera puede avisar, el servidor lleva la
## cuenta de verdad y la reparte.
func anotar_cliente_atendido() -> void:
	_anotar.rpc(1, 0, 0)


## Lo llama quien entregue un pan.
func anotar_pan_entregado() -> void:
	_anotar.rpc(0, 1, 0)


## Lo llama el puesto cuando un cliente se cansa de esperar y se va.
func anotar_cliente_perdido() -> void:
	_anotar.rpc(0, 0, 1)


## Lo llama la interfaz cuando el jugador aprieta seguir en la pantalla de cierre.
func pedir_siguiente_dia() -> void:
	_pedir_siguiente_dia.rpc()


func _conectar_game_manager() -> void:
	var gestor: GameManager = GameManager.instance
	gestor.timer_updated.connect(_al_cambiar_el_reloj)
	gestor.money_updated.connect(_al_cambiar_la_caja)
	_caja_al_empezar = gestor.dinero_recaudado


@rpc("any_peer", "call_local", "reliable")
func _anotar(clientes: int, panes: int, perdidos: int) -> void:
	if not multiplayer.is_server():
		return
	_sumar.rpc(clientes, panes, perdidos)


@rpc("authority", "call_local", "reliable")
func _sumar(clientes: int, panes: int, perdidos: int) -> void:
	_clientes_atendidos += clientes
	_panes_entregados += panes
	_clientes_perdidos += perdidos


@rpc("any_peer", "call_local", "reliable")
func _pedir_siguiente_dia() -> void:
	if not multiplayer.is_server():
		return
	if not _dia_cerrado:
		return
	_empezar_dia.rpc(numero_de_dia + 1)
	if GameManager.instance:
		GameManager.instance.update_time_rpc.rpc(duracion_del_dia)


@rpc("authority", "call_local", "reliable")
func _empezar_dia(numero: int) -> void:
	numero_de_dia = numero
	_clientes_atendidos = 0
	_panes_entregados = 0
	_clientes_perdidos = 0
	_dia_cerrado = false
	if GameManager.instance:
		_caja_al_empezar = GameManager.instance.dinero_recaudado
	avance_cambiado.emit(0, meta_de_monedas)


func _al_cambiar_el_reloj(segundos_restantes: int) -> void:
	if segundos_restantes > 0 or _dia_cerrado:
		return
	if not multiplayer.is_server():
		return
	_cerrar_dia.rpc(numero_de_dia, monedas_del_dia(), _clientes_atendidos, _panes_entregados, _clientes_perdidos)


@rpc("authority", "call_local", "reliable")
func _cerrar_dia(numero: int, monedas: int, clientes: int, panes: int, perdidos: int) -> void:
	_dia_cerrado = true
	dia_terminado.emit(numero, monedas, clientes, panes, perdidos, meta_de_monedas)


func _al_cambiar_la_caja(_cantidad: int) -> void:
	avance_cambiado.emit(monedas_del_dia(), meta_de_monedas)
