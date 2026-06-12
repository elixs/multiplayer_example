class_name HealthComponent
extends MultiplayerSynchronizer

signal died
signal revived
signal health_changed(value: int, max_value: int)
#signal damaged(data: DamageDataResource)
signal healed(amount: int)

@export var armor: int = 0
@export var max_health: int = 100
@export var health: int = 100:
	set(value):
		var new_health = clamp(value, 0, max_health)
		if health == new_health:
			return

		health = new_health
		health_changed.emit(health, max_health)
			
@export var is_dead: bool = false:
	set(value):
		if is_dead == value:
			return
		is_dead = value
		if is_dead:
			died.emit()
		else:
			revived.emit()

func _ready() -> void:
	if is_multiplayer_authority(): #multiplayer.is_server():
		health = max_health
		is_dead = false
		
	health_changed.emit(health, max_health)

func take_damage(damage: int) -> void:
	#if data == null or current_health < 0 or data.amount <= 0:
		#return
	if not multiplayer.is_server() or damage <= 0 or is_dead:
		return
	#current_health = max(current_health - data.amount, 0)
	health = max(health - (damage-armor), 0)
	if health <= 0:
		die()
	#damaged.emit(data)
	#health_changed.emit(health, max_health)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	
func heal(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = min(health + amount, max_health)
	healed.emit(amount)

func revive_full() -> void:
	if not multiplayer.is_server():
		return

	health = max_health
	is_dead = false

func reset_health() -> void:
	health = max_health
	health_changed.emit(health, max_health)
