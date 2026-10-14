class_name Estante
extends ObjetoInteractuable

@export var tipo_de_ingrediente: PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() 
	# Declarar el tipo de objeto

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _execute_interaction() -> void:
	super()
	
	var id_jugador_solicito = multiplayer.get_remote_sender_id()
	_entregar_ingrediente_rpc(id_jugador_solicito)

@rpc("any_peer", "call_local", "reliable")
func _entregar_ingrediente_rpc(id_solicitante: int) -> void:
	var jugador_solicitante = _buscar_jugador(id_solicitante)
	
	if jugador_solicitante:
		var nuevo_ingrediente = tipo_de_ingrediente.instantiate()
		jugador_solicitante.add_child(nuevo_ingrediente)
		nuevo_ingrediente.position = Vector3(0, 1.5, -0.5)
	
func _buscar_jugador(id: int) -> Player:
	for nodo in get_tree().get_nodes_in_group("player"):
		if nodo is Player and nodo.get_multiplayer_authority() == id:
			return nodo
	return null
	
