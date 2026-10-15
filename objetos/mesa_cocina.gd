class_name MesaCocina
extends ObjetoInteractuable

@onready var area_interaccion: CollisionShape3D = $Interaccion_area/CollisionShape3D2
@onready var nodo_ing_1: Marker3D = $Ingrediente1
@onready var nodo_ing_2: Marker3D = $Ingrediente2
var ingredientes: Array[Ingrediente]
var max_ingredientes = 2
var nodos_pos: Array[Marker3D]

func _ready() -> void:
	super()
	nodos_pos.push_back(nodo_ing_1)
	nodos_pos.push_back(nodo_ing_2)

# con q se dejan los ingredientes en la mesa
@rpc("any_peer", "call_local", "reliable")
func _execute_interaction_q(player: Player) -> void:
	if not is_multiplayer_authority():
		return
	
	if len(ingredientes) == max_ingredientes:
		return
	
	if player.objeto_en_mano:
		var pos = nodos_pos[len(ingredientes)].global_position
		var obj: Ingrediente = player.objeto_en_mano
		player.objeto_en_mano.request_ceder(player, pos)
		ingredientes.push_back(obj)
	
