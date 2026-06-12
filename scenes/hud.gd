extends CanvasLayer

@onready var dung: Label = %Dung

func _ready() -> void:
	var current_player_data: Statics.PlayerData = Game.get_current_player()
	
	dung.text = str(current_player_data.dung)
	current_player_data.dung_changed.connect(_on_dung_changed)

func _on_dung_changed(value:int) -> void:
	dung.text = str(value)
	
