class_name Tocomple
extends Node2D

@onready var area_2dd = $Area2D
var selected = false
var come = false
# Called when the node enters the scene tree for the first time.
func _ready():
	area_2dd.body_entered.connect(_on_player_entered)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left_click"):
		selected = true
		
@rpc("call_local", "reliable")
func send_come():
	come = true

func _on_player_entered(body):
	var player = body as Player
	var client= body as Cliente
	#if is_multiplayer_authority():
	if player:#revisar, por esto es que funciona raro el mesón con mesero y chef
			var new_parent = player.get_node(player.get_path())
			#Debug.dprint("hola")
			if selected:
				#Debug.dprint("new_parent")
				get_parent().remove_child(self)
				new_parent.add_child(self)
				position = Vector2.ZERO
	if client:
			var new_parent2 = client.get_node(client.get_path())
			#Debug.dprint("hello")
			if selected:
				#Debug.dprint("new_parent22")
				get_parent().remove_child(self)
				new_parent2.add_child(self)
				position = Vector2.ZERO	
				send_come.rpc()
				#ganancias += 50
				#get_tree().change_scene_to_file("res://scenes/Victoria-menu.tscn")
