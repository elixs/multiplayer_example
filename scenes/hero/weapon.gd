extends Node2D

@onready var body: CollisionShape2D = $body
@onready var skin: Sprite2D = $skin

@export var damage: int = 20

func _physics_process(delta: float) -> void:
	rotation = lerp_angle(rotation, (get_global_mouse_position() - global_position).angle(), 6.5*delta)
