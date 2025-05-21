extends CanvasLayer

signal initiate_round
signal ending_round
signal round_timeout

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

var time_remaining = 0.0
var estado_actual: Estado = Estado.ESPERANDO
var active_builders = 0

func _ready():
	round_timer.wait_time = 1.0
	round_timer.one_shot = false
	round_timer.timeout.connect(_on_round_timer_tick)

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
			if is_multiplayer_authority():
				spawn_building_players.rpc()
		Estado.JUGANDO:
			round_message.visible = false
			if is_multiplayer_authority():
				start_round.rpc()
		Estado.TERMINANDO:
			end_round("Ronda terminada")

	center_message()

@rpc("authority", "call_local")
func start_building_fase():
	cambiar_fase(Estado.CONSTRUCCION)

@rpc("authority", "call_local")
func spawn_building_players():
	active_builders = Game.players.size()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var builder = building_player_scene.instantiate()
		builder.object_scene = object_placeholder_scene
		builder.name = "Builder" + str(i)
		builder.global_position = Vector2(100 + i * 100, 200)
		add_child(builder)
		builder.setup(player_data)
		
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
	round_message.text = message
	round_message.visible = true
	center_message()
	await get_tree().create_timer(3.0).timeout
	round_message.visible = false
	emit_signal("ending_round")

func center_message():
	var screen_size = get_viewport().get_visible_rect().size
	round_message.set_position(screen_size / 2 - round_message.get_size() / 2)
	
func change_text(message: String):
	round_message.text = message
	round_message.visible = true
	center_message()
