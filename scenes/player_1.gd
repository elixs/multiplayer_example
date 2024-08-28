extends CharacterBody2D


var SPEED = 300.0
var JUMP_VELOCITY = 400.0
var ACCELERATION = 1000

var player
# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000

func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)


func _input(event:InputEvent) -> void:
	if is_multiplayer_authority():
		pass
		

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left","move_right")
		velocity.x = move_toward(velocity.x, SPEED* move_input, ACCELERATION * delta)
		if Input.is_action_just_pressed("jump"):
			velocity.y= -JUMP_VELOCITY
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		send_position.rpc(position,velocity)

@rpc()
func send_position(pos:Vector2, vel: Vector2) -> void:
	position = lerp(position,pos,0.5)
	velocity = lerp(velocity,vel,0.5)
