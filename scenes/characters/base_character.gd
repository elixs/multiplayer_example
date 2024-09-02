class_name BaseCharacter
extends Throwable

# Character properties
var health: int = 100
var weapons: Array = Array([], TYPE_OBJECT, "", null)

# Debug
var weapon_scene = preload("res://scenes/weapons/base_weapon.tscn")
var weapon_instance: BaseWeapon = null
@onready var weapon_spawn: Marker2D = $WeaponSpawn
@onready var weapon_spawner: MultiplayerSpawner = $WeaponSpawner
@onready var node: Node = $Node

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
		
		if event.is_action_released("number_1"):
			_on_weapon_instance()

# Phisics
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Only if is autority can grab and throw the character
	if is_multiplayer_authority():
		_send_position.rpc(position)

@rpc
func _send_position(position: Vector2):
	self.position = position 

func _on_weapon_instance():
	if weapon_instance:
		weapon_instance.queue_free()
	weapon_instance = weapon_scene.instantiate()
	node.add_child(weapon_instance, true)
	weapon_instance.global_position = weapon_spawn.global_position
	weapon_instance.setup.rpc(get_multiplayer_authority())
	#weapon_instance.set_multiplayer_authority(name.to_int())
	
