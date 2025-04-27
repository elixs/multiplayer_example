extends Node2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


@onready var destruction_area: Area2D = $EventHorizonArea

func _ready():
	destruction_area.connect("body_entered", Callable(self, "_on_destruction_area_body_entered"))
	anim.play("idle")

func _on_destruction_area_body_entered(body: Node) -> void:
	body.queue_free()
