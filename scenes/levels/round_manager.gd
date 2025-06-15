extends CanvasLayer

signal initiate_round
signal ending_round
signal round_timeout
signal initiate_contruction
enum Estado {
	ESPERANDO,
	CONSTRUCCION,
	JUGANDO,
	TERMINANDO
}

@onready var round_message = $RoundMessage
@onready var timer_label = $TimerLabel
@onready var round_timer = $RoundTimer
@export var round_time: int
@export var building_player_scene: PackedScene
@export var object_placeholder_scene: PackedScene
@export var planeta_scene: PackedScene
@export var agujero_negro_scene: PackedScene

var time_remaining = 0.0
var estado_actual: Estado = Estado.ESPERANDO
var active_builders = 0
@onready var selection_ui = $ObjectSelectionUI
@onready var objetos_seleccionados = {}

func _ready():
	round_timer.wait_time = 1.0
	round_timer.one_shot = false
	round_timer.timeout.connect(_on_round_timer_tick)
	selection_ui.object_selected.connect(enviar_seleccion)
	set_multiplayer_authority(1)	


func _process(_delta):
	if estado_actual == Estado.ESPERANDO:
		round_message.visible = true
		if is_multiplayer_authority():
			round_message.text = "Presiona clic izquierdo para iniciar la ronda"
			if Input.is_action_just_pressed("fire"):
				start_building_fase.rpc()
		else:
			round_message.text = "Esperando a que el host inicie la ronda"
		center_message()
		
func cambiar_fase(nuevo_estado: Estado):
	estado_actual = nuevo_estado
	
	match nuevo_estado:
		Estado.ESPERANDO:
			round_message.text = "Esperando inicio de ronda"
			round_message.visible = true
		Estado.CONSTRUCCION:
			round_message.text = "Fase de Construcción"
			round_message.visible = true
			center_message()
			await get_tree().create_timer(2.0).timeout
			round_message.visible = false
			emit_signal("initiate_contruction")
			if multiplayer.get_unique_id() == 1:
				mostrar_ui_seleccion()
				objetos_seleccionados = {}
				await esperar_seleccion_objetos()
				spawn_building_players.rpc(objetos_seleccionados)
			else:
				mostrar_ui_seleccion()
			
		Estado.JUGANDO:
			round_message.visible = false
			if is_multiplayer_authority():
				start_round.rpc()
		Estado.TERMINANDO:
			end_round("Ronda terminada")

	center_message()
	
func mostrar_ui_seleccion():
	selection_ui.show_ui()

@rpc("any_peer", "call_remote")
func recibir_seleccion(player_id: int, objeto: String):
	print("objetos seleccionados antes de ingresar cambio")
	print(objetos_seleccionados)
	objetos_seleccionados[player_id] = objeto
	print("Jugador %d seleccionó: %s" % [player_id, objeto])
	print("estado actual objetos seleccionados: ")
	print(objetos_seleccionados)

	
func esperar_seleccion_objetos():
		for player_data in Game.players:
			if not objetos_seleccionados.has(player_data.id):
				objetos_seleccionados[player_data.id] = null
		while objetos_seleccionados.values().has(null):
			await get_tree().process_frame
		


func enviar_seleccion(objeto: String):
	var player_id = multiplayer.get_unique_id()
	if is_multiplayer_authority():
		# Host local
		player_id = 1  # O usa un método para obtener ID correcto
		recibir_seleccion(player_id,objeto)
		print("Servidor selecciono de : ", player_id, "con objeto: ", objeto)
	else:
		recibir_seleccion.rpc(player_id, objeto)
		print("Enviando selección de: ", player_id, "con objeto: ", objeto)
	
@rpc("authority", "call_local")
func start_building_fase():
	cambiar_fase(Estado.CONSTRUCCION)

@rpc("authority", "call_local")
func spawn_building_players(objetos_seleccionados_temp):
	print("inicio spawneo de constructores")
	active_builders = Game.players.size()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var builder = building_player_scene.instantiate()
		var player_id = Game.players[i].id
		match objetos_seleccionados_temp[player_id]:
			"Planeta":
				builder.object_scene = planeta_scene
			"Agujero Negro":
				builder.object_scene = agujero_negro_scene
			_:
				builder.object_scene = object_placeholder_scene
		builder.name = "Builder" + str(i)
		builder.global_position = Vector2(100 + i * 100, 200)
		builder.round_manager = self
		get_parent().get_node("BuildingPlayers").add_child(builder)
		builder.setup(player_data)
func notify_building_done():
	active_builders -= 1
	print("Building done por un builder, Builders restantes : " + str(active_builders))

	if active_builders <= 0:
		end_builiding_fase.rpc()

@rpc("authority", "call_local")
func end_builiding_fase():			
	round_message.visible = true
	round_message.text = "iniciando ronda en 3"
	await get_tree().create_timer(1.0).timeout
	round_message.text = "iniciando ronda en 2"
	await get_tree().create_timer(1.0).timeout
	round_message.text = "iniciando ronda en 1"
	await get_tree().create_timer(1.0).timeout
	cambiar_fase(Estado.JUGANDO)
	
@rpc("authority", "call_local")
func start_round():
	time_remaining = round_time
	update_timer_label()
	round_timer.start()
	emit_signal("initiate_round")

func _on_round_timer_tick():
	time_remaining -= 1
	update_timer_label()
	if time_remaining <= 0:
		round_timer.stop()
		timer_label.text = ""
		emit_signal("round_timeout")

func update_timer_label():
	timer_label.text = str(int(time_remaining))
	var screen_size = get_viewport().get_visible_rect().size
	timer_label.set_position(Vector2(
		screen_size.x / 2 - timer_label.size.x / 2,
		20
	))

func end_round(message: String):
	round_timer.stop()
	round_message.text = message
	round_message.visible = true
	center_message()
	await get_tree().create_timer(3.0).timeout
	round_message.visible = false
	emit_signal("ending_round")
	time_remaining = round_time
	update_timer_label()

func center_message():
	var screen_size = get_viewport().get_visible_rect().size
	round_message.set_position(screen_size / 2 - round_message.get_size() / 2)
	
func change_text(message: String):
	round_message.text = message
	round_message.visible = true
	center_message()
