class_name Cliente
extends Node2D


@onready var area_2d = $Area2D

var selected = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if !Input.is_action_pressed("right_click"):
		selected = false
	else:
		selected = true
		
# Called when the node enters the scene tree for the first time.
func _ready():
	var id = multiplayer.get_unique_id()
	var player = Game.get_player(id)
	var role = player.role
	
	if role == 1:
		get_node("Area2D/CollisionShape2D").disabled = true
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

