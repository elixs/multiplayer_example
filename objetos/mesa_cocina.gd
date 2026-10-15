class_name MesaCocina
extends ObjetoInteractuable

@onready var area_interaccion: CollisionShape3D = $Interaccion_area/CollisionShape3D2
@onready var nodo_ing_1: Marker3D = $Ingrediente1
@onready var nodo_ing_2: Marker3D = $Ingrediente2
var ingredientes: Array[Ingrediente]
var max_ingredientes = 2
var nodos_pos: Array[Marker3D]
var nom_ingredientes: Array[String]

func _ready() -> void:
	super()
	nodos_pos.push_back(nodo_ing_1)
	nodos_pos.push_back(nodo_ing_2)

# con q se dejan los ingredientes en la mesa
@rpc("any_peer", "call_local", "reliable")
func _execute_interaction_q() -> void:
	print("ejecutando interaccion q")
	if not multiplayer.is_server():
		print("no tenia la autoridad")
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var player = _get_player_by_peer_id(sender_id)
	
	if player == null or not player.objeto_en_mano:
		print("objeto o player no encontrado")
		return
	
	if len(ingredientes) == max_ingredientes:
		return
	
	var obj: Ingrediente = player.objeto_en_mano
	if obj.nombre_ingrediente in nom_ingredientes:
		return
	
	var pos = nodos_pos[len(ingredientes)].global_position
	
	print("Servidor: cediendo objeto de ", player.name)
	_ceder_objeto_localmente(player, obj, pos)
	print("cediendo en clientes")
	rpc("_sync_deposito", obj.get_path(), pos, len(ingredientes) - 1, player.name)
	
func _ceder_objeto_localmente(player: Player, obj: Ingrediente, pos: Vector3) -> void:
	print("cediendo objeto localmente desde", player.get_instance_id())
	
	player.ceder_objeto(pos)
	ingredientes.push_back(obj)
	nom_ingredientes.push_back(obj.nombre_ingrediente)
	print("ya cedido")
		
@rpc("authority", "call_remote", "reliable")
func _sync_deposito(obj_path: NodePath, pos: Vector3, index: int, player_name: String) -> void:
	var obj = get_node_or_null(obj_path)
	if obj and obj is Ingrediente:
		obj.held_by = -1
		obj.freeze = true
		obj.global_position = pos
		obj.global_rotation = nodos_pos[index].global_rotation
		if index >= len(ingredientes):
			ingredientes.resize(index + 1)
		ingredientes[index] = obj
	
	var p = get_node_or_null("../Players/" + player_name)
	if p and "objeto_en_mano" in p:
		p.objeto_en_mano = null
	
func _get_player_by_peer_id(peer_id: int) -> Player:
	for p in get_tree().get_nodes_in_group("players"):
		if p.get_multiplayer_authority() == peer_id:
			return p
	return null
