extends InteraccionArea

func _ready() -> void:
	duracion_animacion = Objeto_Interactuable.tiempo_accion
	if label:
		label.hide()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("E_Interactuar"):
		for player: Player in players:
			if player.get_multiplayer_authority() == multiplayer.get_unique_id() and player.posicion_actual == player.Posicion.ARRIBA_DE:
				interact.emit()
				print("se emitio la señal desde arriba de ", player.get_instance_id())
				#player.trigger_emotiza.rpc(duracion_animacion)
				return

	if event.is_action_pressed("Q_Interactuar"):
		for player in players:
			if player.get_multiplayer_authority() == multiplayer.get_unique_id() and player.posicion_actual == player.Posicion.ARRIBA_DE:
				interact_q.emit()
				print("se emitio la señal desde arriba de ", player.get_instance_id())
				#player.trigger_emotiza.rpc(duracion_animacion)
				return


func _on_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.push_back(player)
		
		if player.get_multiplayer_authority() == multiplayer.get_unique_id() and player.posicion_actual == player.Posicion.ARRIBA_DE:
			label.show()
			
		
func _on_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.erase(player)
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			label.hide()
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func activar_interaccion(estado: bool) -> void:
	set_deferred("monitoring", estado)
	
	if not estado:
		if label: 
			label.hide()
		players.clear()
