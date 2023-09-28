extends MarginContainer
@onready var conn = $PanelContainer/MarginContainer/VBoxContainer/Conn
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/exit


# Called when the node enters the scene tree for the first time.
func _ready():
	conn.pressed.connect(_on_con)
	exit.pressed.connect(_on_exit)


func _on_con():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")	
	
func _on_exit():
	get_tree().quit()
