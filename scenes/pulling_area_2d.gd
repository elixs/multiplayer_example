extends Area2D


@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	
func _on_body_entered(body):
	print("body entered")
	if body.is_in_group("pullable"):
		pull(body)

func pull(target):
	if not target.has_node("Sprite2D"):
		print("not pullable")
		return
	print("pullable")
	var sprite = target.get_node("Sprite2D")
	var duplicated=sprite.duplicate()
	
	add_child(duplicated)
	duplicated.global_position = sprite.global_position
	target.queue_free()
	var duration = animator.current_animation_length * animator.speed_scale *0.3
	var tween := create_tween()
	tween.tween_property(duplicated, "position", Vector2.ZERO, duration)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(duplicated, "scale", Vector2.ZERO, duration*0.1)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.set_ease(Tween.EASE_IN)
