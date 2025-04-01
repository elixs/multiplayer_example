class_name bullet_boomerang extends proyectile
var rotation_dir:float
var rotation_power: float = 0.01



func _ready() -> void:
	
	$".".speed = 350
	$".".destroy_time = 0.8
	super()
	
	if rotacion_spawn > 0:
		rotation_dir = rotation_power
	else:
		rotation_dir = -rotation_power

func _physics_process(delta: float) -> void:
	
	$".".dir = $".".dir + rotation_dir
	super(delta)
	
