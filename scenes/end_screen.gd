extends Control

@onready var scoreboard_label: Label = $MarginContainer/VBoxContainer/MarginContainer/ScoreboardLabel

func _ready() -> void:
	pass 

func show_results() -> void:
	var sorted_players = Game.players.duplicate()
	sorted_players.sort_custom(func(a, b): return a.dung > b.dung)
	
	var final_text = "-- PUNTAJES --\n"
	var position = 1
	for player_data: Statics.PlayerData in sorted_players:
		var player_name = player_data.name
		var player_score = player_data.dung
		
		final_text += str(position) + "." + player_name + ": " + str(player_score) + "\n"
		position += 1

	scoreboard_label.text = final_text
