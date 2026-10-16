extends InteraccionArea

func _ready() -> void:
	super._ready()

# El cliente se atiende desde arriba de otro gato, así que acá no se mira quién está
# tocando el área sino quién está en la lista del puesto. La tecla se marca como usada
# para que el gato no suelte de paso el pan que lleva en la mano.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("E_Interactuar"):
		for player: Player in players:
			if player.get_multiplayer_authority() == multiplayer.get_unique_id():
				if not manda_sobre(player):
					return
				get_viewport().set_input_as_handled()
				interact.emit()
				return

	if event.is_action_pressed("Q_Interactuar"):
		for player in players:
			if player.get_multiplayer_authority() == multiplayer.get_unique_id():
				if not manda_sobre(player):
					return
				get_viewport().set_input_as_handled()
				interact_q.emit()
				return


func _on_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.push_back(player)
		
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			label.show()
			
		
func _on_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.erase(player)
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			label.hide()
			
func activar_interaccion(estado: bool) -> void:
	set_deferred("monitoring", estado)
	
	if not estado:
		if label: 
			label.hide()
		players.clear()
