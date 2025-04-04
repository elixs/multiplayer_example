class_name bullet_boomerang extends proyectile
var rotation_dir:int # 1 / -1 girar izquiera o derecha la trayectoria curva
var rotation_power: float = -0.01
var rotation_change:float = 0


func _ready() -> void:
	
	$".".speed = 350
	$".".destroy_time = 0.8
	super()
	rotation_dir = -1 #cambiar para que se pueda modificar
	rotation_change = float(rotation_dir) * rotation_power
func _physics_process(delta: float) -> void:
	
	$".".dir = $".".dir + rotation_change
	super(delta)
func _on_body_entered(body):
	super(body)
