extends Node2D

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@export var big_resource: PackedScene

@onready var players: Node2D = $World/Players
@onready var balls: Node2D = $Balls
@onready var spawn_points: Node2D = $PlayerSpawnPoints
@onready var ball_spawn_points: Node2D = $BallSpawnPoints
@onready var match_controller: MatchController = $MatchController
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


var player_instances: Array[Node] = []
var ball_instances: Array[Node] = []

func _ready() -> void:
	_spawn_match_entities()
	_setup_match_controller()

func _spawn_match_entities() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_instance = player_scene.instantiate()
		players.add_child(player_instance, true)
		
		player_instances.append(player_instance) # Agregamos el player
		
		var player_spawn_point = spawn_points.get_child(i)
		player_instance.global_position = player_spawn_point.global_position
		player_instance.setup(player_data)
		player_data.scene = player_instance
		player_instance.respawned.connect(_on_player_respawn.bind(player_instance, player_spawn_point))
		player_instance.died.connect(_on_player_died.bind(player_instance))
		
		var ball_instance = ball_scene.instantiate()
		balls.add_child(ball_instance, true)
		
		ball_instances.append(ball_instance) # Agregamos la bola
		
		var ball_spawn_point = ball_spawn_points.get_child(i)
		ball_instance.global_position = ball_spawn_point.global_position

func _setup_match_controller() -> void:
	match_controller.setup(player_instances, ball_instances, spawn_points)

func _process(delta: float) -> void:
	pass

func _on_player_respawn(player: Player, spawn_point: Node2D) -> void:
		player.global_position = spawn_point.global_position

func _on_player_died(player: Player) -> void:
	if not multiplayer.is_server():
		return
	var total_dung = player._data.dung
	var dropped_dung = total_dung/4
	Game.set_player_dung(player._data.id, total_dung - dropped_dung)
	var resource_ins = big_resource.instantiate()
	# "Cuadrado"
	resource_ins.global_position = player.global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	multiplayer_spawner.call_deferred("add_child", resource_ins, true)
