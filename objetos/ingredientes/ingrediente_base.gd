class_name Ingrediente
extends RigidBody3D

var is_hovered: bool = false
var was_hovered: bool = false
var held_by: int = 0

@export var nombre_ingrediente: String = "placeholder"
@onready var mesh: MeshInstance3D = $MeshInstance3D
#@onready var synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

func _ready() -> void:
	set_multiplayer_authority(1)
	
	if not is_multiplayer_authority():
		freeze = true

func _physics_process(delta: float) -> void:
	
	if not is_multiplayer_authority():
		return
		
	if held_by != 0:
		return
	
	if is_hovered and not was_hovered:
		var fuerza_salto = Vector3.UP * 2.5 * mass
		apply_central_impulse(fuerza_salto)
		
	was_hovered = is_hovered
	is_hovered = false

@rpc("any_peer", "call_local", "reliable")
func request_tomar(player_id: int) -> void:
	
	if not is_multiplayer_authority():
		return
	
	if held_by != 0:
		return
		
	held_by = player_id
	freeze = true
	
	var player = _get_player_by_peer_id(player_id) # (Asegúrate de tener esta función auxiliar en el ingrediente o accesible)
	if player:
		player.objeto_en_mano = self
	
	
	rpc("sync_tomar", player_id)
	
@rpc("any_peer", "call_local", "reliable")
func sync_tomar(player_id: int) -> void:
	held_by = player_id
	
	var player = _get_player_by_peer_id(player_id)
	if player:
		player.objeto_en_mano = self
	
	if not is_multiplayer_authority():
		freeze = true

@rpc("any_peer", "call_local", "reliable")
func request_soltar(player_id: int, throw_velocity: Vector3 = Vector3.ZERO) -> void:
	
	print("se solicita soltar un objeto")
	if not is_multiplayer_authority():
		return
	
	var player = _get_player_by_peer_id(player_id)
	if player:
		player.objeto_en_mano = null
	
	held_by = 0
	freeze = false
	
	if throw_velocity != Vector3.ZERO:
		linear_velocity = throw_velocity
	
	rpc("sync_soltar", player_id, throw_velocity)
	
@rpc("any_peer", "call_local", "reliable")
func sync_soltar(player_id: int, throw_velocity: Vector3 = Vector3.ZERO) -> void:
	print("se sincroniza el soltar")
	var player = _get_player_by_peer_id(player_id)
	if player:
		player.objeto_en_mano = null
	held_by = 0
	freeze = false

@rpc("any_peer", "call_local", "unreliable")
func update_held_position(pos: Vector3, rot: Vector3) -> void:
	if not is_multiplayer_authority():
		return
		
	if held_by <= 0:
		return
	
	global_position = pos
	global_rotation = rot

func soltar_en(pos: Vector3) -> void:
	held_by = -1
	freeze = true
	global_position = pos

func _get_player_by_peer_id(peer_id: int) -> Player:
	for p in get_tree().get_nodes_in_group("players"):
		if p.get_multiplayer_authority() == peer_id:
			return p
	return null
