extends Hitbox

@export var speed = 0
@export var initial_vertical_velocity: float = -200.0
var velocity: Vector2


func _ready() -> void:
	#set_multiplayer_authority(id)
	pass
	
@rpc("any_peer","call_local","reliable")	
func setup(id_: int) -> void:
	#id = id_
	set_multiplayer_authority(id)
	

	

	
	
