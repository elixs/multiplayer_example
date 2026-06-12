extends ItemData

@export var dash: int = 1000

func action(player: Player) -> void:
	player.increase_dash(dash)
