extends ParallaxBackground
@onready var parallax_background = $"."
func _process(delta: float) -> void:
	scroll_offset.x += -40*delta
func _ready() -> void:
	for group in parallax_background.get_groups():
		if group.begins_with("__cameras"):
			parallax_background.remove_from_group(group)
