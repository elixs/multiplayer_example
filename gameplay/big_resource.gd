extends Area2D

func _ready() -> void:
	if is_multiplayer_authority():
		body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D) -> void:
	var player: Player = body as Player
	if player:
		Game.set_player_dung(player.get_id(), Game.get_player_dung(player.get_id()) + 5)
		destroy.rpc()

@rpc("call_local","reliable")
func destroy() -> void: 
	queue_free()
