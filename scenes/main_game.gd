extends Node2D

@export var player_scene: PackedScene

@onready var planets: Node2D = $Planets
@onready var players: Node2D = $Players
@onready var round_manager: CanvasLayer = $RoundManager


func _ready() -> void:
	round_manager.set_multiplayer_authority(1)
	round_manager.cambiar_fase(round_manager.Estado.ESPERANDO)

func _process(delta: float) -> void:
	if round_manager.estado_actual == round_manager.Estado.ESPERANDO and multiplayer.get_unique_id() == 1:
		if Input.is_action_just_pressed("fire"):
			round_manager.start_building_fase.rpc()

@rpc("authority","call_local")
func check_round_state():
	var resultado = get_winner()
	print("se hace check de estado ronda : " + str(resultado))
	if str(resultado) == 'Empate':
		#queda mas de un jugador
		pass
	else:
		round_manager.end_round("¡Fin de la ronda!")
	
func get_winner() -> String:
	var alive_players = []
	for player_node in players.get_children():
		alive_players.append(player_node)
	if alive_players.size() == 1:
		return alive_players[0].name
	elif alive_players.size() > 1:
		return "Empate"
	else:
		return "Nadie"

@rpc("authority","call_local")
func spawn_players():
	print("spawn players")
	for child in players.get_children():
		child.queue_free()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_instance = player_scene.instantiate()
		players.add_child(player_instance)
		player_instance.setup(player_data)
		player_instance.global_position = planets.get_child(i).get_child(4).global_position
		player_instance.spawn_point = planets.get_child(i).get_child(4).global_position
		player_instance.connect("player_death", _on_player_death)

func _on_player_death():
	print("ha muerto un jugador")
	round_manager.end_round("¡Fin de la ronda!")

	#check_round_state.rpc()
	
func _on_round_manager_ending_round() -> void:
	var winner = get_winner()
	if winner != 'Empate':
		round_manager.change_text(winner + " ha ganado la ronda!")
	else:
		round_manager.change_text("Ronda termino en Empate!")
	for child in players.get_children():
		child.queue_free()
	await get_tree().create_timer(3.0).timeout
	round_manager.cambiar_fase(round_manager.Estado.ESPERANDO)

func _on_round_manager_initiate_round() -> void:
	$ConstructionCamera.enabled = false
	if is_multiplayer_authority():
		spawn_players.rpc()

func _on_round_manager_round_timeout() -> void:
	round_manager.end_round("¡El tiempo se ha agotado!")

func _on_round_manager_start_building_phase():
	$ConstructionCamera.enabled = true
	$ConstructionCamera.global_position = Vector2(0, 0)
