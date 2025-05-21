extends CanvasLayer

signal initiate_round
signal ending_round
signal round_timeout

@onready var round_message = $RoundMessage
@onready var waiting_for_start = true
@onready var timer_label = $TimerLabel
@onready var round_timer = $RoundTimer
var time_remaining = 0.0
@export var round_time:int
@export var building_player_scene: PackedScene
@export var object_placeholder_scene: PackedScene
var active_builders = 0

func _ready():
	round_timer.wait_time = 1.0
	round_timer.one_shot = false
	round_timer.timeout.connect(_on_round_timer_tick)

func _process(_delta):
	if waiting_for_start:
		round_message.visible = true
		if is_multiplayer_authority():
			round_message.text = "Presiona clic izquierdo para iniciar la ronda"
			if Input.is_action_just_pressed("fire"):
				start_building_fase.rpc()
		else:
			round_message.text = "Esperando a que el host inicie la ronda"
		
		center_message()


@rpc("authority", "call_local")
func start_round():
	waiting_for_start = false
	round_message.visible = false
	print("Ronda iniciada")
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
	# Centrar el label si lo necesitas manualmente:
	var screen_size = get_viewport().get_visible_rect().size
	timer_label.set_position(Vector2(
		screen_size.x / 2 - timer_label.size.x / 2,
		20  # distancia desde arriba
	))
	
func change_text(message: String):
	round_message.text = message
	round_message.visible = true
	center_message()
	
func end_round(message: String):
	round_message.text = message
	round_message.visible = true
	center_message()
	await get_tree().create_timer(3.0).timeout
	round_message.visible = false
	print("Ronda terminada")
	emit_signal("ending_round")

func center_message():
	var screen_size = get_viewport().get_visible_rect().size
	round_message.set_position(screen_size / 2 - round_message.get_size() / 2)
	
@rpc("authority", "call_local")
func start_building_fase():
	round_message.text = "Fase de Construcción"
	center_message()
	await get_tree().create_timer(2.0).timeout
	if is_multiplayer_authority():
		spawn_building_players.rpc()

@rpc("authority", "call_local")
func spawn_building_players():
	active_builders = Game.players.size()
	for i in Game.players.size():
		var builder = building_player_scene.instantiate()
		builder.object_scene = object_placeholder_scene
		builder.name = "Builder" + str(i)
		builder.global_position = Vector2(100 + i * 100, 200) 
		add_child(builder)
		
func notify_building_done():
	active_builders -= 1
	if active_builders <= 0:
		end_builiding_fase.rpc()
		
		
@rpc("authority", "call_local")
func end_builiding_fase():
	round_message.text = "iniciando ronda en 3"
	await get_tree().create_timer(1.0).timeout
	round_message.text = "iniciando ronda en 2"
	await get_tree().create_timer(1.0).timeout
	round_message.text = "iniciando ronda en 1"
	await get_tree().create_timer(1.0).timeout
	start_round.rpc()
