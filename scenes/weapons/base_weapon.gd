class_name BaseWeapon
extends Throwable

@onready var drag_area: DragArea = $DragArea

@rpc("any_peer", "call_local", "reliable")
func setup(id: int):
	set_multiplayer_authority(id)

# Input management
func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		drag_area.input_action(event, self)

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Only if is autority can grab and throw the character
	if is_multiplayer_authority():
		_send_position.rpc(position, rotation)

@rpc
func _send_position(position: Vector2, rotation: float):
	self.position = position 
	self.rotation = rotation
