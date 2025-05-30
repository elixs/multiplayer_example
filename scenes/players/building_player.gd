extends Node2D

@export var object_scene: PackedScene
@onready var sprite = $Sprite2D
@onready var object_preview = $ObjectPreview
@onready var label: Label = $Label
var round_manager: CanvasLayer

var placed_object: Node2D = null
var is_active = true

func _ready():
	if object_scene:
		placed_object = object_scene.instantiate()
		object_preview.add_child(placed_object)
		placed_object.visible = true
		set_object_opacity(placed_object, 0.5) 

func _process(_delta):
	if is_active and is_multiplayer_authority():
		global_position = get_global_mouse_position()

		if Input.is_action_pressed("right_click"):
			sprite.visible = false
			if placed_object:
				set_object_opacity(placed_object, 1.0)  # Opaco
		else:
			sprite.visible = true
			if placed_object:
				set_object_opacity(placed_object, 0.5)  # Semitransparente

		if Input.is_action_just_pressed("left_click") and placed_object:
			place_object.rpc()

func setup(player_data: Statics.PlayerData):
	label.text = player_data.name
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local")
func place_object():
	is_active = false

	var final_object = object_scene.instantiate()
	final_object.global_position = global_position
	get_parent().get_parent().add_child(final_object)

	if round_manager != null:
		round_manager.notify_building_done()



	queue_free()

func set_object_opacity(node: Node, alpha: float) -> void:
	if node is CanvasItem:
		node.modulate.a = alpha
	for child in node.get_children():
		set_object_opacity(child, alpha)
