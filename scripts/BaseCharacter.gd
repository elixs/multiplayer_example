extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var agent = $NavigationAgent3D
var target: Vector3

@onready var camera_3d = $Camera3D
@onready var animation_player = $AnimationPlayer
@onready var arrows = $Arrows
@onready var arrows_transform = $ArrowsTransform

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	look_at(target)
	rotation.x = 0
	rotation.y = 0
	if Input.is_action_pressed("Move"):
		target = screenPointToRay()
		if Input.is_action_just_pressed("Move"):
			target.y = 0.2
			arrows_transform.global_position = target
			animation_player.play("move_arrows")
		target.y = 0
		updateTargetLocation(target)
	if position.distance_to(target) > 0.5:
		var current_position = global_transform.origin
		var target_position = agent.get_next_path_position()
		var new_velocity = (target_position - current_position).normalized() * SPEED
		velocity = new_velocity
		move_and_slide()

	#move_and_slide()
	
func screenPointToRay():
	var space_state = get_world_3d().direct_space_state
	var mouse_position = get_viewport().get_mouse_position()
	var ray_origin = camera_3d.project_ray_origin(mouse_position)
	var ray_end = ray_origin + camera_3d.project_ray_normal(mouse_position) * 2000
	var args = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var ray_array = space_state.intersect_ray(args)
	if ray_array.has("position"):
		return ray_array["position"]
	return Vector3()
	
func updateTargetLocation(target):
	agent.target_position = target
