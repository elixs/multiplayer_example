class_name Tocomple
extends Node2D

@onready var area_2d = $Area2D
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area_2d.body_entered.connect(_on_player_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		selected = true

func _on_player_entered(body):
	var player = body as Player
	if player:
		var new_parent = player.get_node(player.get_path())
		Debug.dprint("hola")
		if selected:
			Debug.dprint("new_parent")
			get_parent().remove_child(self)
			new_parent.add_child(self)
			position = Vector2.ZERO
			
