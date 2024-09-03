class_name Hurtbox
extends Area2D

signal been_stunned()

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	

func _on_area_entered(area: Area2D) -> void:
		var hitbox = area as Hitbox
		if hitbox==null:
			return
		if hitbox.owner != owner:
			if owner.has_method("stun"):
				owner.stun()
				Debug.log(owner.get_multiplayer_authority())
