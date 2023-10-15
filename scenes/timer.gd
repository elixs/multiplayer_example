extends Control

@export var minutes = 0
@export var seconds = 0
@export var dsec = 0
@onready var min = $min
@onready var sec = $sec


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if seconds > 0 and dsec <= 0:
		seconds -=1
		dsec = 10
	
	if minutes > 0 and seconds <= 0:
		minutes -=1
		seconds = 60
		
	if minutes >= 10:
		min.set_text(str(minutes))
	else:
		min.set_text("0"+str(minutes))
		
	if seconds >= 10:
		sec.set_text(str(seconds))
	else:
		sec.set_text("0"+str(seconds))
		

func _on_timer_timeout():
	dsec -= 1 
