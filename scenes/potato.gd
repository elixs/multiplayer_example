extends Hitbox

@export var speed = 600
@export var initial_vertical_velocity: float = -200.0
@export var id: int
var velocity: Vector2




func _ready() -> void:
	set_multiplayer_authority(id)
	# Initialize velocity for horizontal and vertical motion
	velocity.x = speed
	velocity.y = initial_vertical_velocity
	
@rpc("any_peer","call_local","reliable")	
func setup(id: int) -> void:
	set_multiplayer_authority(id)


func _physics_process(delta: float) -> void:
	# Apply gravity to the vertical velocity
	velocity.y += gravity * delta
	
	# Update position based on the velocity
	position += velocity * delta
