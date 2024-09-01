extends CharacterBody3D

@export var speed = 4
@export var friction = 0.1
@export var acceleration = 0.1
@export var rotation_speed = 0.5 # Controla qué tan rápido gira el personaje
@export var camera_offset = Vector3(0, 2, -5) # Posición relativa de la cámara

var target_velocity = Vector3.ZERO
var direction = Vector3.FORWARD

func _physics_process(delta):
	if is_multiplayer_authority():
		## Rotación del personaje
		if Input.is_action_pressed("move_left"):
			$Pivot.rotate_y(rotation_speed * delta)
			
		if Input.is_action_pressed("move_right"):
			$Pivot.rotate_y(-rotation_speed * delta)
		sync_rotation.rpc($Pivot.rotation)
		
		# Actualizar la dirección del personaje según su orientación
		direction = -$Pivot.basis.z.normalized()

		# Movimiento hacia adelante y atrás
		if Input.is_action_pressed("move_forward"):
			target_velocity.x = move_toward(target_velocity.x, direction.x * speed, acceleration)
			target_velocity.z = move_toward(target_velocity.z, direction.z * speed, acceleration)
		elif Input.is_action_pressed("move_back"):
			target_velocity.x = move_toward(target_velocity.x, -direction.x * speed, acceleration)
			target_velocity.z = move_toward(target_velocity.z, -direction.z * speed, acceleration)
		else:
			# Frenado gradual si no se presionan las teclas de mover adelante/atrás
			target_velocity.x = move_toward(target_velocity.x, 0, friction)
			target_velocity.z = move_toward(target_velocity.z, 0, friction)

		# Mover al personaje
		velocity = target_velocity
		send_position.rpc(velocity, direction)
		
	move_and_slide()
	# Actualizar la posición de la cámara
	#update_camera()
	
@rpc
func send_position(vel : Vector3, dir : Vector3) -> void:
	velocity = vel
	direction = dir

@rpc("call_remote", "unreliable")
func sync_rotation(new_rotation: Vector3) -> void:
	$Pivot.rotation = new_rotation

#func update_camera():
	# Colocar la cámara detrás del personaje, ajustando la posición según el offset
	#var camera_global_transform = $Pivot.global_transform
	#$Camera3D.global_transform.origin = camera_global_transform.origin + (camera_global_transform.basis * camera_offset)

#func _input(event: InputEvent) -> void:
	#if is_multiplayer_authority():
		#if event.is_action_pressed("test"):
			#test.rpc()
#
#@rpc("authority", "call_local", "unreliable")
#func test():
	#Debug.log("test")

func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	
	set_multiplayer_authority(player_data.id)
	Debug.log("admin")
	Debug.log(player_data.id)
