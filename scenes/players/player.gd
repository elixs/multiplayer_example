extends CharacterBody2D

@export var max_speed = 300
@export var acceleration = 5000
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var label: Label = $Label
@onready var pivot: Node2D = $pivot

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var move_input = Input.get_vector("move_left", "move_right","move_up","move_down")
		velocity= velocity.move_toward(move_input * max_speed, acceleration * delta)
		send_data.rpc(position, velocity)
	
	move_and_slide()

	if velocity.x:
		playback.travel("walk")
		pivot.scale.x = sign(velocity.x)
	else:
		playback.travel("idle")

@rpc("unreliable_ordered")
func send_data(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.3)
	velocity = vel
