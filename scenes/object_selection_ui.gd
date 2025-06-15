extends CanvasLayer

signal object_selected(objeto: String)

@onready var buttons_container = $CenterContainer/Panel/MarginContainer/VBoxContainer/ButtonsContainer

# Lista de objetos disponibles
var available_objects = [
	{ "name": "Planeta", "texture": preload("res://assets/planets/earth.png") },
	{ "name": "Agujero Negro", "texture": preload("res://assets/structures/Template_Sprite_black_hole_128.png") },
	{ "name": "mass_relay", "texture": preload("res://assets/structures/mass_relay.png") },
]
func _ready():
	visible = false

func show_ui():
	visible = true
	_clear_buttons()

	# Elegir 2 objetos aleatorios
	var shuffled = available_objects.duplicate()
	shuffled.shuffle()
	var selected = shuffled.slice(0, 2)

	for obj in selected:
		var button = Button.new()
		button.text = ""  # Sin texto, solo imagen
		button.icon = obj["texture"]
		button.expand_icon = true
		button.custom_minimum_size = Vector2(96, 96)
		button.connect("pressed", Callable(self, "_on_object_pressed").bind(obj["name"]))
		buttons_container.add_child(button)

func _on_object_pressed(objeto: String):
	emit_signal("object_selected", objeto)
	visible = false

func _clear_buttons():
	for child in buttons_container.get_children():
		child.queue_free()
