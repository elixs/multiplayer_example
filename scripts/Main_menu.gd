extends MarginContainer

@onready var conn = %conn
@onready var exit = %exit

# Called when the node enters the scene tree for the first time.
func _ready():
	conn.pressed.connect(_on_conn_pressed)
	exit.pressed.connect(_on_exit_pressed)

func _on_conn_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_exit_pressed():
	get_tree().quit()
	
