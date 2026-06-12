class_name MatchController
extends Node

signal state_changed(new_state: MatchState)

enum MatchState {
	GAME_STARTING,
	GAME_PLAYING,
	GAME_SHOP,
	GAME_ENDING
}

@export var respawn_delay: float = 10.0
@export_range(0.0, 1.0, 0.05) var death_drop_ratio: float = 0.25
@export_range(0.0, 1.0, 0.05) var death_keep_ratio: float = 0.25
@onready var shop_screen: Control = $"../UI/ShopScreen"
@onready var round_timer: Timer = $"../Timers/RoundTimer"
@onready var match_timer: Timer = $"../Timers/MatchTimer"
@onready var end_screen: Control = $"../UI/EndScreen"
@onready var shop_timer: Timer = $"../Timers/ShopTimer"
@onready var timer_label: Label = $"../UI/TimerLabel"

var current_state: MatchState = MatchState.GAME_STARTING

var players: Array[Node] = []
var balls: Array[Node] = []
var spawn_points: Node2D

var _respawn_timers: Dictionary = {}
var _pending_respawn_players: Array[Node] = []

func setup(match_players: Array[Node], match_balls: Array[Node], match_spawn_points: Node2D) -> void:
	players = match_players
	balls = match_balls
	spawn_points = match_spawn_points

	if multiplayer.is_server():
		_connect_player_death_signals()

func _ready() -> void:
	shop_screen.hide()
	end_screen.hide()
	match_timer.timeout.connect(_on_match_timer_timeout)
	round_timer.timeout.connect(_on_round_timer_timeout)
	shop_timer.timeout.connect(_on_shop_timer_timeout)
	# OJO se debe haber ejecutado setup()
	start_match()
	
func _connect_player_death_signals() -> void:
	for player in players:
		if not is_instance_valid(player):
			continue

		var health_component: HealthComponent = player.get_node_or_null("HealthComponent")
		if health_component == null:
			continue
		# Es necesario? Las señales siempre deberían estar conectadas previamente
		if not health_component.died.is_connected(_on_player_died):
			health_component.died.connect(_on_player_died.bind(player))

func start_match() -> void:
	change_state(MatchState.GAME_STARTING)
	match_timer.start()
	start_round()

func start_round() -> void:
	change_state(MatchState.GAME_PLAYING)
	shop_screen.hide()
	#_set_gameplay_enabled(true)
	round_timer.start()

func enter_shop() -> void:
	change_state(MatchState.GAME_SHOP)
	#_set_gameplay_enabled(false)
	shop_screen.show()
	#if shop_screen.has_method("refresh_shop"):
	#	shop_screen.refresh_shop()
	shop_timer.start()
	get_tree().paused = true

func exit_shop() -> void:
	shop_screen.hide()
	get_tree().paused = false
	start_round()

func end_match() -> void:
	end_screen.show_results()
	end_screen.show()
	change_state(MatchState.GAME_ENDING)
	_set_gameplay_enabled(false)

func change_state(new_state: MatchState) -> void:
	if current_state == new_state:
		return

	current_state = new_state
	state_changed.emit(new_state)


func _set_gameplay_enabled(enabled: bool) -> void:
	for player in players:
		if player.has_method("set_gameplay_enabled"):
			player.set_gameplay_enabled(enabled)

	for ball in balls:
		if ball.has_method("set_gameplay_enabled"):
			ball.set_gameplay_enabled(enabled)
			
func _on_round_timer_timeout() -> void:
	enter_shop()

func _on_shop_timer_timeout() -> void:
	exit_shop()
	
func _on_match_timer_timeout() -> void:
	end_match()

func _process(delta: float) -> void:
	update_timer_label()
	
func update_timer_label() -> void:
	match current_state:
		MatchState.GAME_PLAYING:
			timer_label.text = "Round Timer: " + str(int(round(round_timer.time_left)))

		MatchState.GAME_SHOP:
			timer_label.text = "Shop Timer: " + str(int(round(shop_timer.time_left)))

		MatchState.GAME_STARTING:
			timer_label.text = "Starting..."

		MatchState.GAME_ENDING:
			timer_label.text = "Game Over"
			
func _on_player_died(player: Player) -> void:
	if not multiplayer.is_server():
		return

	if not is_instance_valid(player):
		return

	#_apply_death_resource_penalty(player)
	#_drop_player_death_resources(player)

	#_queue_respawn(player)
