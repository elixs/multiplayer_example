extends HSlider

var menu_bus = AudioServer.get_bus_index("Niveles")
@onready var menu_volume = $"."

func _ready():
	menu_volume.value =AudioServer.get_bus_volume_db(menu_bus)
	
func _on_value_changed(value):
	AudioServer.set_bus_volume_db(menu_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(menu_bus,true)
	else:
		AudioServer.set_bus_mute(menu_bus,false)

