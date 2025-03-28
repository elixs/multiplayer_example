extends CharacterBody2D
@export var speed = 100

var pos_spawn:Vector2
var rotacion_spawn:float
var dir:float
func _ready():
	global_position = pos_spawn
	global_rotation = rotacion_spawn
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed,0).rotated(dir)
	move_and_slide()
	
