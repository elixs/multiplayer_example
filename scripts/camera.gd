extends Camera2D

@onready var screen_size: Vector2 = get_viewport_rect().size
@onready var player: CharacterBody2D = $"../Hero"

func _ready() -> void:
	_set_screen_position()
	await get_tree().process_frame
	position_smoothing_enabled = true
	position_smoothing_speed = 7.0

func _process(delta: float) -> void:
	_set_screen_position()
	
func _set_screen_position():
	var player_pos = player.global_position
	var x = floor(player_pos.x / screen_size.x) * screen_size.x * 3 / 2
	var y = floor(player_pos.y / screen_size.y) * screen_size.y * 3 / 2
	global_position = Vector2(x,y)
	
