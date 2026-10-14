class_name Ingrediente
extends RigidBody3D

var is_hovered: bool = false
var was_hovered: bool = false
var held_by: int = 0

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
	
	rpc("sync_tomar", player_id)
	
@rpc("any_peer", "call_local", "reliable")
func sync_tomar(player_id: int) -> void:
	held_by = player_id
	
	if not is_multiplayer_authority():
		freeze = true

@rpc("any_peer", "call_local", "reliable")
func request_soltar(throw_velocity: Vector3 = Vector3.ZERO) -> void:
	
	if not is_multiplayer_authority():
		return
		
	held_by = 0
	freeze = false
	
	if throw_velocity != Vector3.ZERO:
		linear_velocity = throw_velocity
	
	rpc("sync_soltar", throw_velocity)
	
@rpc("any_peer", "call_local", "reliable")
func sync_soltar(throw_velocity: Vector3 = Vector3.ZERO) -> void:
	held_by = 0
	if not is_multiplayer_authority():
		freeze = false
		#if throw_velocity != Vector3.ZERO:
			#linear_velocity = throw_velocity
			
@rpc("any_peer", "call_local", "unreliable")
func update_held_position(pos: Vector3, rot: Vector3) -> void:
	if not is_multiplayer_authority():
		return
	
	global_position = pos
	global_rotation = rot
