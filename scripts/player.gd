extends CharacterBody3D


const CANNON_BALL = preload("res://scenes/cannon_ball.tscn")


@onready var label = $Label3D
@onready var camera = $Camera/CameraTarget/SpringArm3D/Camera3D  # Asumiendo que tu cámara está directamente bajo el nodo de jugador

@export var speed = 0.3
@export var friction = 0.995
@export var rotation_speed = 0.3 # Controla qué tan rápido gira el personaje
@export var max_velocity = 0.2

var direction = Vector3.FORWARD # Vector (0,0,-1)
var axis = Vector3.UP 
var rotation_velocity = 0


func _physics_process(delta):
	if is_multiplayer_authority():
		# Disparo
		if Input.is_action_just_pressed("fire"):
			shoot_cannon_ball()
		# Movimiento hacia adelante
		if Input.is_action_pressed("move_forward"):
			velocity += direction * speed * delta
		# Movimiento hacia y atrás
		if Input.is_action_pressed("move_back"):
			velocity += -direction * speed * delta * 0.5

		# Movimiento hacia adelante
		if Input.is_action_pressed("move_right"):
			direction = direction.rotated(-axis, rotation_speed * delta).normalized()
		# Movimiento hacia y atrás
		if Input.is_action_pressed("move_left"):
			direction = direction.rotated(axis, rotation_speed * delta).normalized()
	
	# Friccion
	velocity = velocity * friction
	
	velocity.x = clamp(velocity.x, -max_velocity, max_velocity)
	velocity.z = clamp(velocity.z, -max_velocity, max_velocity)
	
	position += velocity
	look_at(global_transform.origin + direction, axis)
	
	send_position.rpc(position, direction)
	move_and_slide()
	
@rpc
func send_position(pos : Vector3, dir : Vector3) -> void:
	position = pos
	direction = dir


func shoot_cannon_ball() -> void:
	if multiplayer.is_server():
		spawn_cannon_ball(global_position, direction.rotated(axis, 0.5 * PI))
		rpc_id(0, "spawn_cannon_ball", global_position, direction.rotated(axis, 0.5 * PI))
	else:
		rpc_id(1, "request_shoot", global_position, direction.rotated(axis, 0.5 * PI))

@rpc("call_local", "reliable")
func request_shoot(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	if multiplayer.is_server():
		spawn_cannon_ball(spawn_position, spawn_direction)
		rpc_id(0, "spawn_cannon_ball", spawn_position, spawn_direction)

@rpc("any_peer", "call_local", "reliable")
func spawn_cannon_ball(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	var cannon_ball_node = CANNON_BALL.instantiate()
	cannon_ball_node._set_direction(spawn_direction)
	get_parent().add_child(cannon_ball_node)
	cannon_ball_node.global_position = spawn_position

	
func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	label.text = player_data.name

	if is_multiplayer_authority():
		camera.current = true
	else:
		# Desactiva la cámara si es un jugador remoto
		camera.current = false
	Debug.log("admin")
	Debug.log(player_data.id)
