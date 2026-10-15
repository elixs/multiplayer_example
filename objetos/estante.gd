class_name Estante
extends ObjetoInteractuable

@export var tipo_de_ingrediente: PackedScene 
@onready var nodo_spawn: Marker3D = $SpawnPoint
@onready var spawner_ingrediente: MultiplayerSpawner = $IngredientSpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() 

@rpc("any_peer", "call_local", "reliable")
func _execute_interaction() -> void:
	print("ejecutando interaccion e")
	if not is_multiplayer_authority():
		print("no tenia la autoridad")
		return
	
	if not tipo_de_ingrediente:
		return
		
	var nombre_unico = "Ingrediente_" + str(Time.get_ticks_msec())
	
	print("spawneando objeto localmente")
	_spawn_ingrediente_localmente(nodo_spawn.global_position, nombre_unico)
	
	_comunicar_spawn_a_clientes.rpc(nodo_spawn.global_position, nombre_unico)

@rpc("authority", "call_remote", "reliable")
func _comunicar_spawn_a_clientes(posicion_global: Vector3, nombre_nodo: String) -> void:
	print("spawneando objeto en clientes")
	_spawn_ingrediente_localmente(posicion_global, nombre_nodo)

func _spawn_ingrediente_localmente(posicion_global: Vector3, nombre_nodo: String) -> void:
	var nuevo_ingrediente = tipo_de_ingrediente.instantiate()
	nuevo_ingrediente.name = nombre_nodo
	add_child(nuevo_ingrediente)
	nuevo_ingrediente.global_position = posicion_global
	
