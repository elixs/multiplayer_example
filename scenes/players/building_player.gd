extends Node2D

@export var object_scene: PackedScene
@onready var sprite = $Sprite2D
@onready var object_preview = $ObjectPreview

var placed_object: Node = null
var is_active = true

func _ready():
	if object_scene:
		placed_object = object_scene.instantiate()
		object_preview.add_child(placed_object)
		placed_object.visible = false

func _process(_delta):
	if is_active:
		global_position = get_global_mouse_position()

		if Input.is_action_pressed("right_click"):
			sprite.visible = false
			if placed_object:
				placed_object.visible = true
		else:
			sprite.visible = true
			if placed_object:
				placed_object.visible = false

		if Input.is_action_just_pressed("left_click") and placed_object:
			place_object()

func place_object():
	is_active = false

	var final_object = object_scene.instantiate()
	final_object.global_position = global_position
	get_tree().get_root().add_child(final_object)

	if get_parent().has_method("notify_building_done"):
		get_parent().notify_building_done()

	queue_free()
