class_name BaseWeapon
extends Throwable

@onready var drag_area: DragAreaNode = $DragArea

func _ready() -> void:
	throw_power = 50


@rpc("any_peer", "call_local", "reliable")
func setup(id: int):
	set_multiplayer_authority(id)

# Input management
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		drag_area.input_action(event)

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Only if is autority can grab and throw the character
	if is_multiplayer_authority():
		_send_position.rpc(position, rotation)

@rpc
func _send_position(pos: Vector2, rot: float):
	self.position = pos 
	self.rotation = rot
