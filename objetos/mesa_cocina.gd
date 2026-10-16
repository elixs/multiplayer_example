class_name MesaCocina
extends ObjetoInteractuable

@onready var area_interaccion: CollisionShape3D = $Interaccion_area/CollisionShape3D2
@onready var nodo_ing_1: Marker3D = $Ingrediente1
@onready var nodo_ing_2: Marker3D = $Ingrediente2
@onready var nodo_ing_3: Marker3D = $Ingrediente3
@onready var nodo_listo: Marker3D = $IngredienteListo
var ingredientes: Array[Ingrediente]
var max_ingredientes = 3
var nodos_pos: Array[Marker3D]
var nom_ingredientes: Array[String]
var recibe_ingredientes: bool = true
var dummy_ing = preload("res://objetos/ingredientes/dummy_ing.tscn") as PackedScene

# quizas seria bueno hacer un tipo receta y manejar los pasos (recetas desbloqueadas)
# desde el game manager
# key: String, val: PackedScene (ingrediente para que se pueda tomar)
# el string es la concatenacion con + de los nombres de los ingredientes en orden alfabetico
var pasos: Dictionary = {
	"agua+harina": preload("res://objetos/ingredientes/amasado_crudo.tscn") as PackedScene,
	"amasado_crudo": dummy_ing,
	"agua+harina+levadura": preload("res://objetos/ingredientes/masa_madre_cruda.tscn") as PackedScene,
	"masa_madre_cruda": dummy_ing
}

func _ready() -> void:
	super()
	nodos_pos.push_back(nodo_ing_1)
	nodos_pos.push_back(nodo_ing_2)
	nodos_pos.push_back(nodo_ing_3)

# con q se dejan los ingredientes en la mesa
@rpc("any_peer", "call_local", "reliable")
func _execute_interaction_q() -> void:
	#calcular lo necesario
	print("ejecutando interaccion q")
	if not recibe_ingredientes:
		print("no recibe ings")
		return
	
	if not multiplayer.is_server():
		print("no tenia la autoridad")
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var player = _get_player_by_peer_id(sender_id)
	
	if player == null or not player.objeto_en_mano:
		print("objeto o player no encontrado")
		return
	
	if len(ingredientes) >= max_ingredientes:
		print("demasiados ingredientes")
		return
	
	var obj: Ingrediente = player.objeto_en_mano
	if obj.nombre_ingrediente in nom_ingredientes:
		print("ingrediente ya en la mesa")
		return
	
	var index_actual = len(ingredientes)
	var pos = nodos_pos[len(ingredientes)].global_position
	
	print("Servidor: cediendo objeto de ", player.name)
	# actualizar objetos
	_ceder_objeto_localmente(player, obj, pos)
	print("cediendo en clientes")
	# sincronizar
	rpc("_sync_deposito", obj.get_path(), pos, index_actual, player.name)
	
func _ceder_objeto_localmente(player: Player, obj: Ingrediente, pos: Vector3) -> void:
	print("cediendo objeto localmente desde", player.get_instance_id())
	
	player.ceder_objeto(pos)
	ingredientes.push_back(obj)
	nom_ingredientes.push_back(obj.nombre_ingrediente)
	print("ya cedido")
		
@rpc("authority", "call_remote", "reliable")
func _sync_deposito(obj_path: NodePath, pos: Vector3, index: int, player_name: String) -> void:
	var obj = get_node_or_null(obj_path) as Ingrediente
	if obj and obj is Ingrediente:
		obj.held_by = -1
		obj.freeze = true
		obj.global_position = pos
		obj.global_rotation = nodos_pos[index].global_rotation
		if index >= len(ingredientes):
			ingredientes.resize(index + 1)
			nom_ingredientes.resize(index + 1)
		ingredientes[index] = obj
		nom_ingredientes[index] = obj.nombre_ingrediente
	
	var p = get_node_or_null("../Players/" + player_name)
	if p and "objeto_en_mano" in p:
		p.objeto_en_mano = null
	
func _get_player_by_peer_id(peer_id: int) -> Player:
	for p in get_tree().get_nodes_in_group("players"):
		if p.get_multiplayer_authority() == peer_id:
			return p
	return null

# con e se cocina y se toma el resultado
@rpc("any_peer", "call_local", "reliable")
func _execute_interaction() -> void:
	if not is_multiplayer_authority():
		return
	
	var next = _buscar_en_pasos()
	# si hay paso que hacer, hacerlo
	if next != null and next != dummy_ing:
		print("existe siguiente paso")
		# borrar ingredientes
		recibe_ingredientes = false
		
		var rutas_a_borrar: Array = []
		for i in range(ingredientes.size()):
			var ing = ingredientes[0]
			rutas_a_borrar.append(ing.get_path())
			ingredientes.remove_at(0)
			var ind = nom_ingredientes.find(ing.nombre_ingrediente)
			nom_ingredientes.remove_at(ind)
			
		# spawnear el siguiente
		var nombre_unico = "Ingrediente_" + str(Time.get_ticks_msec())
		
		_procesar_cocina_en_todos.rpc(rutas_a_borrar, next.resource_path, nombre_unico)
	
	# soltar el ingrediente
	else:
		print("next == dummy o no hay receta")
		
		if ingredientes.size() == 0:
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
			
		var ing_a_recuperar: Ingrediente = ingredientes.pop_back()
		nom_ingredientes.erase(ing_a_recuperar.nombre_ingrediente)

		# Si la mesa se quedó sin ingredientes, permitimos recibir de nuevo
		#if ingredientes.size() == 0:
		recibe_ingredientes = true

		ing_a_recuperar.global_position = nodo_listo.global_position
		ing_a_recuperar.request_tomar.rpc_id(1, sender_id)
#
		# Sincronizamos la entrega del objeto a todos los clientes
		#_sync_recuperar.rpc(ing_a_recuperar.get_path(), player.name)
		
	
# llamar solo si hay ingredientes en la mesa
func _buscar_en_pasos() -> PackedScene:
	nom_ingredientes.sort()
	var packed_noms = PackedStringArray(nom_ingredientes)
	var llave = "+".join(packed_noms)
	print("llave: ", llave)
	if llave in pasos.keys():
		return pasos[llave]
	return dummy_ing


@rpc("authority", "call_local", "reliable")
func _procesar_cocina_en_todos(rutas_a_borrar: Array, scene_path: String, nombre_unico: String) -> void:
	# 1. Borrar los ingredientes en cada máquina (servidor y clientes)
	for ruta in rutas_a_borrar:
		print("ruta a borrar: ", ruta)
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
		nuevo_ingrediente.global_position = nodo_ing_1.global_position
		ingredientes.push_back(nuevo_ingrediente)
		nom_ingredientes.push_back(nuevo_ingrediente.nombre_ingrediente)
	
	print("ingredientes en la mesa:")
	for i in ingredientes:
		print(i)
		
@rpc("authority", "call_local", "reliable")
func _soltar_ingrediente_listo_en_todos() -> void:
	pass

@rpc("authority", "call_local", "reliable")
func _sync_recuperar(obj_path: NodePath, player_name: String) -> void:
	var obj = get_node_or_null(obj_path) as Ingrediente
	var p = get_node_or_null("../Players/" + player_name) as Player

	if obj and obj is Ingrediente and p:
		# Desvinculamos el objeto de la mesa para que vuelva a ser un objeto libre en el mundo
		if obj.get_parent() == self:
			remove_child(obj)
			# Lo volvemos a poner en la escena principal (o donde vivan los objetos sueltos)
			#get_tree().current_scene.add_child(obj)
			
		# Restauramos sus físicas para que el shape_cast o la interacción normal del jugador lo detecte/pueda tomar
		obj.freeze = false
		
		# Si prefieres una asignación limpia reutilizando tu lógica de inventario:
		p.objeto_en_mano = obj
		obj.held_by = p.get_multiplayer_authority()
