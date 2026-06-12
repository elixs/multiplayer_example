extends ItemData

@export var speed: float = 1.1

func action(player: Player) -> void:
	player.increase_velocity(speed)
