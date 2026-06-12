extends ItemData

@export var armor: int = 1

func action(player: Player) -> void:
	player.increase_armor(armor)
