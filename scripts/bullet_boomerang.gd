class_name bullet_boomerang extends proyectile
var rotation_dir:float



func _ready() -> void:
	
	$".".speed = 350
	$".".destroy_time = 0.8
	super()
	
	##temporal deberia llegar como variable al disparar por ahora es fijo
	rotation_dir = 0.01

func _physics_process(delta: float) -> void:
	
	$".".dir = $".".dir + rotation_dir
	super(delta)
	
