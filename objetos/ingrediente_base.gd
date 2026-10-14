class_name Ingrediente
extends RigidBody3D

var is_hovered = false
var was_hovered = false

@onready var mesh: MeshInstance3D = $MeshInstance3D
#var original_material: StandardMaterial3D
#var highlight_material: StandardMaterial3D

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#original_material = StandardMaterial3D.new()
	#original_material.albedo_color = Color(0.8, 0.2, 0.2)
	#
	#highlight_material = original_material.duplicate()
	#highlight_material.emission_enabled = true
	#highlight_material.emission = Color(0.2, 0.5, 1.0)
	#highlight_material.emission_energy_multiplier = 1.0
#
	#mesh.material_override = original_material

func _physics_process(delta: float) -> void:
	if is_hovered and not was_hovered:
		
		#mesh.material_override = highlight_material
		
		var fuerza_salto = Vector3.UP * 2.5 * mass
		apply_central_impulse(fuerza_salto)
		
	#elif not is_hovered and was_hovered:
		#mesh.material_override = original_material
		
	was_hovered = is_hovered
	is_hovered = false
