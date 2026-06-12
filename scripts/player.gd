class_name Player
extends CharacterBody2D

signal respawned
signal died

@export var walk_speed: int = 200
@export var flight_speed: int = 600
@export var acceleration: float = 400
@export var rotation_speed: float = 5
@export var projectile_scene: PackedScene

var _data: Statics.PlayerData
var _speed: int = walk_speed

@onready var label: Label = $Pivot/Label
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var camera_2d: Camera2D = $Camera2D
@onready var input_synchronizer: InputSyncronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer
@onready var dung_recolected: int = 0
@onready var projectile_spawner: MultiplayerSpawner = $ProjectileSpawner
@onready var projectile_spawn_marker: Marker2D = $Pivot/ProjectileSpawnMarker
@onready var health_component: HealthComponent = $HealthComponent
@onready var hb: HB = $HB
@onready var health_bar: ProgressBar = $HealthBar
@onready var hud: CanvasLayer = $HUD
@onready var respawn_timer: Timer = $RespawnTimer


@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

@onready var pivot: Node2D = $Pivot
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var spear: Spear = $WeaponPivot/Weapons/Spear

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	health_component.revived.connect(_on_revived)
	sync_timer.timeout.connect(_on_sync_timeout)
	if projectile_scene: # Para proyectiles propios del player
		projectile_spawner.add_spawnable_scene(projectile_scene.resource_path)
 	
	hb.health_bar.max_value = health_component.max_health
	hb.health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	respawn_timer.timeout.connect(_on_respawn_timeout)
	health_bar.value = health_component.health

func _physics_process(delta: float) -> void:
	var move_input: Vector2 = input_synchronizer.move_input
	if input_synchronizer.mode_input:
		# Flight mode
		if input_synchronizer.flight_input:
			_speed = flight_speed
		else:
			_speed = walk_speed
		# Normal Movement
		velocity.x = move_toward(velocity.x, move_input.x * _speed, acceleration * delta)
		velocity.y = move_toward(velocity.y, move_input.y * _speed, acceleration * delta)
		if velocity.length() > 0:
			var angle = velocity.angle() + PI / 2
			pivot.rotation = lerp_angle(pivot.rotation, angle, rotation_speed * delta)
		# Weapon movement and fire
		if is_multiplayer_authority():
			weapon_pivot.rotation = global_position.direction_to(get_global_mouse_position()).angle()
			#Debug.log("Cambio de rotación:", weapon_pivot.rotation)
			if Input.is_action_just_pressed("fire_main_weapon"):
				#fire()
				spear.fire()
	else:
		# Movement with ball attached
		pivot.rotation += move_input.x * rotation_speed * delta
		var forward_direction = Vector2.UP.rotated(pivot.rotation)
		velocity = velocity.move_toward(forward_direction * _speed * move_input.y, acceleration * delta)
	move_and_slide()
	
	if input_synchronizer.move_input:
		if input_synchronizer.flight_input:
			playback.travel("fly")
		else:
			playback.travel("walk")
	else:
		if get_real_velocity().is_zero_approx():
			playback.travel("idle")

func setup(data: Statics.PlayerData) -> void:
	_data = data
	name = str(data.id)
	label.text = data.name
	set_multiplayer_authority(data.id, false)
	multiplayer_synchronizer.set_multiplayer_authority(data.id, false)
	input_synchronizer.set_multiplayer_authority(data.id, false)
	#health_component.set_multiplayer_authority(1, false)
	camera_2d.enabled = is_multiplayer_authority()
	hb.visible = is_multiplayer_authority()
	health_bar.visible = not is_multiplayer_authority()
	#pivot.set_multiplayer_authority(data.id, false)
	if is_multiplayer_authority():
		sync_timer.start()


@rpc("authority", "call_remote", "unreliable_ordered")
func send_position(pos: Vector2) -> void:
	global_position = lerp(global_position, pos, 0.5)
	

## Not used for now, but it should get used later when the shoot animation have got implemented
#func fire_one_shot(one_shot_name: String) -> void:
	##animation_tree["parameters/%s/request" % one_shot_name] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	## now it should call fire() methon (i'll change the name in the future)
	#pass

func _on_sync_timeout() -> void:
	if is_multiplayer_authority(): # HOTFIX
		send_position.rpc(global_position)
		
func _on_health_changed(value: int, max_value: int) -> void:
	var deb: String = str("HP: ", value, "/", max_value)
	Debug.log(deb)
	hb.health_bar.value = value
	health_bar.value = value
	# UI local, barra de vida, efectos visuales simples.

func _on_died() -> void:
	var deb: String = str("Player died visually: ", name)
	Debug.log(deb)
	_apply_dead_state(true)
	died.emit()

	if multiplayer.is_server():
		#_handle_server_death_logic()
		respawn_timer.start()
		
func _on_revived() -> void:
	respawned.emit()
	await get_tree().create_timer(0.5).timeout
	_apply_dead_state(false)
	
func _apply_dead_state(dead: bool) -> void:
	#visible = not dead
	set_physics_process(not dead)
	
	if is_multiplayer_authority():
		if dead:
			sync_timer.stop()
		elif sync_timer.is_stopped():
			sync_timer.start()

	if hurtbox_component:
		hurtbox_component.is_enabled = not dead
	if collision_shape_2d:
		collision_shape_2d.set_deferred("disabled", dead)
	if weapon_pivot:
		weapon_pivot.visible = not dead
	pivot.visible = not dead
	
	health_bar.visible = not dead and not is_multiplayer_authority()
	hud.visible = is_multiplayer_authority()
	velocity = Vector2.ZERO

func apply_respawn_position(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO

func get_id() -> int:
	return _data.id
	
func increase_max_healt(value:int) -> void:
	var max_healt_increase = int(health_component.max_health*0.10)
	health_component.max_health += max_healt_increase
	health_component.health += max_healt_increase
	hb.health_bar.max_value = health_component.max_health
	hb.health_bar.value = health_component.health
	health_bar.max_value = health_component.max_health
	health_bar.value = health_component.health

func increase_velocity(value:int) -> void:
	walk_speed = walk_speed*value

func _on_respawn_timeout() -> void:
	health_component.revive_full()
	
func increase_dash(value:int) -> void:
	flight_speed += value
	Debug.log(flight_speed)
	
func increase_armor(value:int) -> void:
	health_component.armor = value
