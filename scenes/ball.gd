extends StaticBody2D

var _near_players: Array[Node2D]
var attached_player: Player
var is_attached: bool = false

var distance: float = 150
var follow_speed: float = 8.0

@onready var area_2d: Area2D = $Area2D
@onready var barrier: Area2D = $Barrier
@onready var sprite_2d: Sprite2D = $Sprite2D

var last_position: Vector2 = Vector2.ZERO
var current_offset: Vector2 = Vector2.ZERO

func _ready() -> void:
		area_2d.body_entered.connect(_on_body_entered)
		area_2d.body_exited.connect(_on_body_exit)
		barrier.area_entered.connect(_on_area_entered)
		last_position = global_position
		
func _physics_process(delta: float) -> void:
	if is_attached:
		var player_forward = Vector2.RIGHT.rotated(attached_player.pivot.rotation + PI/2)
		var target_pos = attached_player.global_position + (player_forward * distance)
		global_position = global_position.lerp(target_pos, follow_speed * delta)
		
	var displacement = global_position - last_position
	
	if displacement != Vector2.ZERO:
		# Factor in the sprite's global scale so the texture rolls 
		# relative to its visible size, not its giant 2048x2048 texture size
		var visible_width = sprite_2d.texture.get_width() * sprite_2d.global_scale.x
		var visible_height = sprite_2d.texture.get_height() * sprite_2d.global_scale.y
		
		current_offset.x -= displacement.x / visible_width
		current_offset.y -= displacement.y / visible_height
		
		sprite_2d.set_instance_shader_parameter("texture_offset", current_offset)
	
	last_position = global_position
	
func _input(event: InputEvent) -> void:
	var player: Player = Game.get_current_player().scene
	if event.is_action_pressed("input_movement_mode"):
		if _near_players.has(player):
			if !is_attached:
				attach.rpc(player.get_path())
			else:
				if player == attached_player:
					detach.rpc(player.get_path())
					
@rpc("any_peer", "call_local", "reliable")
func attach(player_path: NodePath) -> void:
	var player: Player = get_node(player_path)
	if !attached_player:
		attached_player = player
	if attached_player == player:
		set_collision_mask_value(1, false)
		set_collision_layer_value(1, false)
		is_attached = true
		player.input_synchronizer.mode_input = false

@rpc("any_peer", "call_local", "reliable")
func detach(player_path: NodePath) -> void:
	var player: Player = get_node(player_path)
	set_collision_mask_value(1, true)
	set_collision_layer_value(1, true)
	is_attached = false
	player.input_synchronizer.mode_input = true

func _on_body_entered(body: Node2D) -> void:
	var player = body as Player
	if player:
		_near_players.push_back(player)

func _on_area_entered(area: Area2D) -> void:
	var projectile: Projectile = area as Projectile
	Debug.log("xao")
	if projectile:
		Debug.log("xao")
		if is_multiplayer_authority():
			#await get_tree().create_timer(0.05).timeout
			projectile.queue_free()

func _on_body_exit(body: Node2D) -> void:
	_near_players.erase(body)
