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
				start_round.rpc()  
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
	timer_label.text = str(int(time_remaining)) + "s"
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
