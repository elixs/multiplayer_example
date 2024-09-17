class_name Hurtbox
extends Area2D


@export var reach: CollisionShape2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	

func _on_area_entered(area: Area2D) -> void:
		var hitbox = area as Hitbox
		if hitbox==null:
			return
		if hitbox.id != owner.get_multiplayer_authority():
			if owner.has_method("stun"):
				owner.stun()
				var pos_otro = 0
				if owner.pos == 0:
					pos_otro = 1
				Main.players.get_child(pos_otro).set_potato_state(false)	
				owner.potato_changed(hitbox.id)
				if area.is_in_group("potato"):
					area.queue_free()
