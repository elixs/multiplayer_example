class_name PuestoCliente
extends ObjetoInteractuable

@export var ocupado: bool = false:
	set(value):
		if ocupado != value:
			ocupado = value
			_actualizar_animacion()
			if interaccion_area:
				interaccion_area.activar_interaccion(ocupado)

@onready var modelo: Node3D = $modelo
var pos_visible: Vector3
var pos_oculta: Vector3

func _ready() -> void:
	super._ready()
	
	pos_visible = modelo.position
	pos_oculta = pos_visible - Vector3(0, 2, 0) 
	modelo.position = pos_oculta
	if interaccion_area:
		interaccion_area.activar_interaccion(ocupado)

func _actualizar_animacion() -> void:
	if not is_inside_tree(): return
	var tween: Tween = create_tween()
	
	if ocupado:
		tween.tween_property(modelo, "position", pos_visible, 0.6).set_trans(Tween.TRANS_SPRING)
	else:
		tween.tween_property(modelo, "position", pos_oculta, 0.4).set_trans(Tween.TRANS_SINE)

@rpc("any_peer", "call_local", "reliable")
func _execute_interaction() -> void:
	if not multiplayer.is_server(): return
	
	if ocupado:
		var peer_id = multiplayer.get_remote_sender_id()
		print("Servidor: Jugador ", peer_id, " atendió el puesto ", name)
		
		# Aquí sumamos puntos entregas etc xd
		
		_set_ocupado_rpc.rpc(false)

@rpc("call_local", "reliable")
func _set_ocupado_rpc(estado: bool) -> void:
	ocupado = estado
