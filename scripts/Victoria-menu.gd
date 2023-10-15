extends MarginContainer

@onready var m_menu = $PanelContainer/MarginContainer/VBoxContainer/m_menu
@onready var exit = $PanelContainer/MarginContainer/VBoxContainer/exit

# Called when the node enters the scene tree for the first time.
func _ready():
	m_menu.pressed.connect(_on_menu)
	exit.pressed.connect(_on_exit)

func _on_menu():
	get_tree().change_scene_to_file("res://scenes/Main_menu.tscn")	
	
func _on_exit():
	get_tree().quit()

