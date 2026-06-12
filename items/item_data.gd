class_name ItemData
extends Resource

@export var display_name: String = ""
@export_multiline() var description = ""
@export var image: Texture2D
@export var price: int = 10


func action(player: Player) -> void:
	pass
