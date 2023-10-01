extends MarginContainer

@onready var resume = $VBoxContainer/resume
@onready var menu_p = $VBoxContainer/Menu_p
@onready var quit = $VBoxContainer/quit

func _ready():
	hide()
	resume.pressed.connect(_on_resume_pressed)
	#retry.pressed.connect(_on_retry_pressed)
	menu_p.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(func(): get_tree().quit())
	Game.paused.connect(_on_game_paused)

func _input(event):
	if is_multiplayer_authority():
		if event.is_action_pressed("pause"):
			Game.pause.rpc(!get_tree().paused)

func _on_resume_pressed():
	Game.pause.rpc(false)
	
func _on_retry_pressed():
	pass
	
func _on_main_menu_pressed():
	pass

func _on_game_paused():
	visible = get_tree().paused
