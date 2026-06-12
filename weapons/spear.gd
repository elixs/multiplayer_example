class_name Spear
extends Node2D

@export var projectile_scene: PackedScene
@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner
@onready var projectile_spawn_marker_spear: Marker2D = $ProjectileSpawnMarkerSpear



func _ready() -> void:
	if projectile_scene:
		projectile_spawner.add_spawnable_scene(projectile_scene.resource_path)

func fire() -> void:
	Debug.log("FIRE FIRE FIREE")
	#var direction: Vector2 = projectile_spawn_marker.global_position.direction_to(get_global_mouse_position())
	fire_server.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func fire_server() -> void:
	if not projectile_scene:
		return
	var projectile_ins: Projectile = projectile_scene.instantiate()
	projectile_ins.global_position = projectile_spawn_marker_spear.global_position
	projectile_ins.global_rotation = projectile_spawn_marker_spear.global_rotation
	projectile_spawner.add_child(projectile_ins, true)
