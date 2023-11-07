extends StaticBody2D

var packed_tocomple = preload("res://scenes/tocomple.tscn")
@onready var spawn = $completospawn
@onready var tocomple = $tocomple

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_tocomple():
	#return tocomple
	return get_tree().get_nodes_in_group("tocomples")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var hay_tocomple = get_node("tocomple")
	#var hay_tocomple = get_node_or_null("res://scenes/tocomple.tscn")
	if hay_tocomple == null:
		var new_tocomple = packed_tocomple.instantiate()
		add_child(new_tocomple)
		new_tocomple.global_position = spawn.global_position
