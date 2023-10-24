class_name Meson
extends StaticBody2D

@onready var area_2d = $Area2D
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	area_2d.body_entered.connect(_on_player_entered)
	pass # Replace with function body.
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		selected = true

@rpc("call_local", "reliable", "any_peer")
func drop_completo(path):
	var tocomple = get_node(path)
	tocomple.get_parent().remove_child(tocomple)
	add_child(tocomple)
	tocomple.position = Vector2.ZERO
	
func _on_player_entered(body):
	var player = body as Player
	#if is_multiplayer_authority():
	if player:
		var tocomple = player.get_tree().get_nodes_in_group("tocomples")[0]
		#Debug.dprint(self)
		if selected:
			if tocomple != null:
				drop_completo.rpc(tocomple.get_path())
				selected = false
			else:
				selected = false
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
