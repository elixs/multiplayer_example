extends CharacterBody2D
@export var speed = 100

var zona_colision:CollisionShape2D
var pos_spawn:Vector2
var rotacion_spawn:float
var dir:float
var animation:AnimatedSprite2D
func _ready():
	global_position = pos_spawn
	global_rotation = rotacion_spawn
	zona_colision = $CollisionShape2D
	animation = $AnimatedSprite2D
func _physics_process(delta: float) -> void:
	velocity = Vector2(speed,0).rotated(dir)
	var collision = move_and_collide(velocity*delta)
	if collision:
		explode()

@rpc("authority","call_local","reliable")
func explode():
	animation.animation = "explode"
	velocity = Vector2(0,0)
	

	
