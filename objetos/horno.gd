extends ObjetoInteractuable

@onready var nodo_ing: Marker3D = $Ingrediente

var ingrediente: Ingrediente
var dummy_ing = preload("res://objetos/ingredientes/dummy_ing.tscn") as PackedScene
var pasos: Dictionary = {
	"amasado_crudo": preload("res://objetos/ingredientes/amasado.tscn") as PackedScene,
	"masa_madre_cruda": preload("res://objetos/ingredientes/masa_madre.tscn") as PackedScene,
	"masa_madre": dummy_ing,
	"amasado": dummy_ing
}

@rpc("any_peer", "call_local", "reliable")
func _execute_interaction_q() -> void:
	#calcular lo necesario
	print("ejecutando interaccion q")
	
	if not multiplayer.is_server():
		print("no tenia la autoridad")
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var player = _get_player_by_peer_id(sender_id)
	
	if player == null or not player.objeto_en_mano:
		print("objeto o player no encontrado")
		return
	
	if ingrediente:
		print("demasiados ingredientes")
		return
	
	var obj: Ingrediente = player.objeto_en_mano
	
	var pos = nodo_ing.global_position
	
	print("Servidor: cediendo objeto de ", player.name)
	# actualizar objetos
	_ceder_objeto_localmente(player, obj, pos)
	print("cediendo en clientes")
	# sincronizar
	rpc("_sync_deposito", obj.get_path(), pos, player.name)
	
func _ceder_objeto_localmente(player: Player, obj: Ingrediente, pos: Vector3) -> void:
	print("cediendo objeto localmente desde", player.get_instance_id())
	
	player.ceder_objeto(pos)
	ingrediente = obj
	print("ya cedido")
		
@rpc("authority", "call_remote", "reliable")
func _sync_deposito(obj_path: NodePath, pos: Vector3, player_name: String) -> void:
	var obj = get_node_or_null(obj_path) as Ingrediente
	if obj and obj is Ingrediente:
		obj.held_by = -1
		obj.freeze = true
		obj.global_position = pos
		obj.global_rotation = nodo_ing.global_rotation
		ingrediente = obj
	
	var p = get_node_or_null("../Players/" + player_name)
	if p and "objeto_en_mano" in p:
		p.objeto_en_mano = null
	
func _get_player_by_peer_id(peer_id: int) -> Player:
	for p in get_tree().get_nodes_in_group("players"):
		if p.get_multiplayer_authority() == peer_id:
			return p
	return null

@rpc("any_peer", "call_local", "reliable")
func _execute_interaction() -> void:
	if not is_multiplayer_authority():
		return
		
	if not ingrediente: 
		return
	
	var next = _buscar_en_pasos()
	# si hay paso que hacer, hacerlo
	if next != null and next != dummy_ing:
		print("existe siguiente paso")
		# borrar ingredientes
		
		var ruta_a_borrar = ingrediente.get_path()
			
		# spawnear el siguiente
		var nombre_unico = "Ingrediente_" + str(Time.get_ticks_msec())
		
		_procesar_cocina_en_todos.rpc(ruta_a_borrar, next.resource_path, nombre_unico)
	
	# soltar el ingrediente
	else:
		print("next == dummy o no hay receta")
		
		if not ingrediente:
			print("No hay ingredientes en la mesa para tomar.")
			return
			
		# Obtenemos quién hizo la interacción
		var sender_id = multiplayer.get_remote_sender_id()
		# Si fue el servidor el que interactuó localmente, su ID de emisor remoto puede ser 0 o 1
		if sender_id == 0:
			sender_id = 1
			
		var player = _get_player_by_peer_id(sender_id)
		if player == null:
			print("Jugador no encontrado para entregar el objeto.")
			return

		var ing_a_recuperar = ingrediente
		ingrediente = null
		ing_a_recuperar.global_position = nodo_ing.global_position
		ing_a_recuperar.request_tomar.rpc_id(1, sender_id)

	
# llamar solo si hay ingredientes en la mesa
func _buscar_en_pasos() -> PackedScene:
	var llave = ingrediente.nombre_ingrediente
	if llave in pasos.keys():
		return pasos[llave]
	return dummy_ing


@rpc("authority", "call_local", "reliable")
func _procesar_cocina_en_todos(ruta: NodePath, scene_path: String, nombre_unico: String) -> void:
	# 1. Borrar los ingredientes en cada máquina (servidor y clientes)
	var nodo_a_borrar = get_node_or_null(ruta)
	if nodo_a_borrar:
		print("Eliminando ingrediente visualmente: ", ruta)
		nodo_a_borrar.queue_free()

	# 2. Spawnear el nuevo ingrediente resultante en cada máquina
	var scene = load(scene_path) as PackedScene
	if scene:
		var nuevo_ingrediente: Ingrediente = scene.instantiate()
		print("Spawneando resultado: ", nuevo_ingrediente.nombre_ingrediente)
		nuevo_ingrediente.name = nombre_unico
		add_child(nuevo_ingrediente)
		nuevo_ingrediente.freeze = true
		nuevo_ingrediente.global_position = nodo_ing.global_position
		ingrediente = nuevo_ingrediente
	
	print("ingredientes en el horno: ", ingrediente.nombre_ingrediente)


@rpc("authority", "call_local", "reliable")
func _sync_recuperar(obj_path: NodePath, player_name: String) -> void:
	var obj = get_node_or_null(obj_path) as Ingrediente
	var p = get_node_or_null("../Players/" + player_name) as Player

	if obj and obj is Ingrediente and p:
		# Desvinculamos el objeto de la mesa para que vuelva a ser un objeto libre en el mundo
		if obj.get_parent() == self:
			remove_child(obj)
			# Lo volvemos a poner en la escena principal (o donde vivan los objetos sueltos)
			get_tree().current_scene.add_child(obj)
			
		# Restauramos sus físicas para que el shape_cast o la interacción normal del jugador lo detecte/pueda tomar
		obj.freeze = false
		
		# Si prefieres una asignación limpia reutilizando tu lógica de inventario:
		p.objeto_en_mano = obj
		obj.held_by = p.get_multiplayer_authority()
