class_name BaseCharacter
extends Throwable

# Character properties
var health: int = 100
var weapons: Array = Array([], TYPE_OBJECT, "", null)

# Visual properties
@onready var drag_area: DragArea = $DragArea

# multiplayer setup
func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)

func _ready() -> void:
	pass

# Input management
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		drag_area.input_action(event, self)

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_multiplayer_authority():
		_send_position.rpc(position)

@rpc
func _send_position(position: Vector2):
	self.position = position 
