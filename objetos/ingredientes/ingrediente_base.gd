class_name Ingrediente
extends RigidBody3D

var is_hovered: bool = false
var held_by: int = 0

# Con qué choca el ingrediente mientras anda suelto por la cocina. Se guardan para poder
# devolvérselas, porque en la mano se le sacan: un cuerpo congelado en la mano seguía
# empujando al gato y a los muebles, y eso era lo que descolocaba toda la cocina.
var _capa_suelta: int = 0
var _mascara_suelta: int = 0

@export var nombre_ingrediente: String = "placeholder"
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label3D = $Label3D

func _ready() -> void:
	set_multiplayer_authority(1)
	
	_capa_suelta = collision_layer
	_mascara_suelta = collision_mask
	
	if not is_multiplayer_authority():
		freeze = true
	
	if label:
		label.hide()
		label.text = "Presionar E para tomar"

# El cartel aparece mientras el gato de esta máquina tiene el ingrediente al frente.
# Antes, además, el ingrediente pegaba un salto cada vez que alguien lo miraba, y por eso
# la cocina parecía moverse sola.
func _process(_delta: float) -> void:
	if label:
		label.visible = is_hovered and held_by == 0
	is_hovered = false
	if held_by != 0:
		var player = _get_player_by_peer_id(held_by)
		if player != null and "nodo_agarre" in player and player.nodo_agarre != null:
			global_position = player.nodo_agarre.global_position
			global_rotation = player.nodo_agarre.global_rotation


# En la mano el objeto se mueve a mano, cuadro a cuadro, así que se congela en modo
# cinemático, que es el que Godot espera cuando un cuerpo se coloca desde el código.
# Congelado como estático la física lo trataba como un mueble que aparece de golpe en
# cada posición nueva.
func _congelar_en_la_mano() -> void:
	freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	freeze = true


func _soltar_del_congelado() -> void:
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	if is_multiplayer_authority():
		freeze = false


func _apagar_colisiones() -> void:
	collision_layer = 0
	collision_mask = 0


func _encender_colisiones() -> void:
	collision_layer = _capa_suelta
	collision_mask = _mascara_suelta

@rpc("any_peer", "call_local", "reliable")
func request_tomar(player_id: int) -> void:
	
	if not is_multiplayer_authority(): return
	if held_by != 0: return

	sync_tomar.rpc(player_id)
	
@rpc("any_peer", "call_local", "reliable")
func sync_tomar(player_id: int) -> void:
	held_by = player_id
	_congelar_en_la_mano()
	_apagar_colisiones()
	
	var sync_node = get_node_or_null("MultiplayerSynchronizer")
	if sync_node:
		sync_node.process_mode = Node.PROCESS_MODE_DISABLED
		
	var player = _get_player_by_peer_id(player_id)
	if player:
		player.objeto_en_mano = self
	

@rpc("any_peer", "call_local", "reliable")
func request_soltar(player_id: int, throw_velocity: Vector3 = Vector3.ZERO) -> void:
	
	print("se solicita soltar un objeto")
	if not is_multiplayer_authority():
		return
	
	sync_soltar.rpc(player_id, throw_velocity)
	
@rpc("any_peer", "call_local", "reliable")
func sync_soltar(player_id: int, throw_velocity: Vector3 = Vector3.ZERO) -> void:
	print("se sincroniza el soltar")
	var player = _get_player_by_peer_id(player_id)
	if player:
		player.objeto_en_mano = null
	held_by = 0
	_soltar_del_congelado()
	_encender_colisiones()
	var sync_node = get_node_or_null("MultiplayerSynchronizer")
	if sync_node:
		sync_node.process_mode = Node.PROCESS_MODE_INHERIT

# El objeto se pega a la mano. Antes se acercaba con un lerp de 0.05 por cuadro, así que
# iba siempre varios pasos atrás del gato y parecía que flotaba suelto.
#@rpc("any_peer", "call_local", "unreliable")
#func update_held_position(pos: Vector3, _rot: Vector3) -> void:
	#if not is_multiplayer_authority():
		#return
		
	#if held_by <= 0:
		#return
	
	#global_position = pos

func soltar_en(pos: Vector3) -> void:
	held_by = -1
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	_encender_colisiones()
	global_position = pos

func _get_player_by_peer_id(peer_id: int) -> Player:
	for p in get_tree().get_nodes_in_group("players"):
		if p.get_multiplayer_authority() == peer_id:
			return p
	return null
