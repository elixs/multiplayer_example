extends CharacterBody3D

const CANNON_BALL = preload("res://scenes/cannon_ball.tscn")

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
			_shoot_cannon_ball()
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

func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	Debug.log("admin")
	Debug.log(player_data.id)

func _shoot_cannon_ball() -> void:
	var cannon_ball_node = CANNON_BALL.instantiate()
	cannon_ball_node._set_direction(direction.rotated(axis, 0.5 * PI))
	get_parent().add_child(cannon_ball_node)
	cannon_ball_node.global_position = position
