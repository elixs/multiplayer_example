extends CanvasLayer

signal object_selected(objeto: String)

@onready var button_planeta = $MarginContainer/VBoxContainer/HBoxContainer/ButtonPlaneta
@onready var button_agujero = $MarginContainer/VBoxContainer/HBoxContainer/ButtonAgujero

func _ready():
	button_planeta.pressed.connect(_on_planeta_pressed)
	button_agujero.pressed.connect(_on_agujero_pressed)
	visible = false

func _on_planeta_pressed():
	emit_signal("object_selected", "Planeta")
	visible = false

func _on_agujero_pressed():
	emit_signal("object_selected", "Agujero Negro")
	visible = false

func show_ui():
	visible = true
