extends Node2D

@onready var body: CollisionShape2D = $body
@onready var skin: Sprite2D = $skin

@export var damage: int = 20

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		var target_angle = (get_global_mouse_position() - global_position).angle()
		var new_rotation = lerp_angle(rotation, target_angle, 6.5*delta)
		rotation = new_rotation
		_update_weapon_rotation.rpc(new_rotation)

#func setup(player_data: Statics.PlayerData):
	#set_multiplayer_authority(player_data.id)

@rpc("call_local")
func _update_weapon_rotation(new_rotation: float):
	rotation = new_rotation
