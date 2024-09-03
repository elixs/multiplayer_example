extends Timer

@onready var state_machine:Node  = $"../StateMachine"


# Called when the node enters the scene tree for the first time.
func _ready():
	wait_time = 3.0  # Espera 1 segundo
	one_shot = true
	timeout.connect(_on_Timer_timeout)# Replace with function body.


func _on_Timer_timeout() -> void:
	Debug.log("bua")
	state_machine.is_frozen = false
