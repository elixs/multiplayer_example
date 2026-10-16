class_name PuestoCliente
extends ObjetoInteractuable

@export var ocupado: bool = false:
	set(value):
		if ocupado != value:
			ocupado = value
			_actualizar_animacion()
			if interaccion_area:
				interaccion_area.activar_interaccion(ocupado)
var receta_actual: String = ""

@onready var label_pedido: Label3D = $LabelPedido
var pedido_revelado: bool = false

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
		label_pedido.text = ""
		tween.tween_property(modelo, "position", pos_oculta, 0.4).set_trans(Tween.TRANS_SINE)

@rpc("call_local", "reliable")
func configurar_pedido_rpc(estado: bool, receta: String = "") -> void:
	receta_actual = receta
	pedido_revelado = false
	ocupado = estado
	
	if ocupado:
		label_pedido.text = "?"
		# TODO: Actualizar aquí visualmente la burbuja con el nombre/imagen de receta_actual
		print("Puesto actualizó su receta a: ", receta_actual)

@rpc("call_local", "reliable")
func revelar_pedido_rpc() -> void:
	pedido_revelado = true
	label_pedido.text = receta_actual # ¡O el nombre de la receta!
	print("PuestoCliente: ¡Pedido revelado! Quiere: ", receta_actual)

@rpc("any_peer", "call_local", "reliable")
func _execute_interaction() -> void:
	if not multiplayer.is_server(): return
	print("miau")
	if not ocupado: return
	
	var peer_id = multiplayer.get_remote_sender_id()
	if peer_id == 0: peer_id = multiplayer.get_unique_id()
	
	# Buscar al jugador que interactuó
	var nodo_jugador = get_tree().root.find_child(str(peer_id), true, false)
	var jugador = nodo_jugador as Player
	
	if not jugador:
		print("Servidor: No se pudo encontrar al jugador ", peer_id)
		return
		
	if not pedido_revelado:
		if jugador.posicion_actual == jugador.Posicion.ARRIBA_DE:
			revelar_pedido_rpc.rpc()
		else:
			print("Servidor: Jugador en el suelo intentó hablar, pero no alcanza. ¡Necesitas subirte arriba de otro!")
		return

	if pedido_revelado:
		if jugador.objeto_en_mano != null:
			var plato_entregado:String = jugador.objeto_en_mano.nombre_ingrediente # O jugador.objeto_en_mano.id_receta
			
			if plato_entregado == receta_actual:
				print("Servidor: ¡Entrega Exitosa! El jugador ", peer_id, " entregó ", plato_entregado)
				
				# Quitar el plato de la mano
				jugador.objeto_en_mano.queue_free()
				jugador.objeto_en_mano = null
				#jugador.vaciar_manos_rpc.rpc()
				
				var recetaMiau = Recetario.instance.recetas.buscar_por_id(plato_entregado)
				GameManager.instance.añadir_dinero(recetaMiau.precio_venta)
				#Jornada.instance.anotar_cliente_atendido()
				#Jornada.instance.anotar_pan_entregado()
				
				# Quitar al cliente (poner ocupado en false)
				configurar_pedido_rpc.rpc(false, "")
			else:
				print("Servidor: Comida incorrecta. El cliente quiere: ", receta_actual, " pero le diste: ", plato_entregado)
		else:
			print("Servidor: El pedido ya fue revelado, pero no llevas comida para entregar.")
