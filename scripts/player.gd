extends CharacterBody3D

# How fast the player moves in meters per second.
@export var speed = 4
@export var friction = 0.1

@export var acceleration = 0.1

# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration = 0

var target_velocity = Vector3.ZERO


func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	print(direction.length())
	if direction.length() != 0:
		target_velocity.x = move_toward(target_velocity.x, direction.x * speed, acceleration)
		target_velocity.z = move_toward(target_velocity.z, direction.z * speed, acceleration)
	
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, friction)
		target_velocity.z = move_toward(target_velocity.z, 0, friction)
		
	
		
	# Ground Velocity
	
	

	# Vertical Velocity
	#if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
	#	target_velocity.y = target_velocity.y - (fall_acceleration * delta)

	# Moving the Character
	velocity = target_velocity
	move_and_slide()
