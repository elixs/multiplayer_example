class_name HurtboxComponent
extends Area2D

#signal damage_received(data: DamageDataResource)

@export var is_enabled: bool = true
@export var health_component: HealthComponent 

func _ready() -> void:
	if multiplayer.is_server():
		area_entered.connect(_on_area_entered)


func _on_area_entered(area: Area2D) -> void:
	if not is_enabled or health_component == null or health_component.is_dead:
		return
	var hitbox: HitboxComponent = area as HitboxComponent
	if hitbox and health_component:
		if hitbox.owner == owner: # No se puede pegar a sí mismo
			return
		health_component.take_damage(hitbox.damage)	
		#hitbox.damage_dealt.emit()
		
