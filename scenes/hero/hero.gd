extends CharacterBody2D

@onready var skin: Sprite2D = $Skin
@onready var body: CollisionShape2D = $Body
@onready var area_daño: Area2D = $Area_daño
@onready var life: ProgressBar = $Life

@export var health: int = 100

@export var speed: int = 350 
@export var acceleration: int = 10

@export var dash_speed: int = 5000
var dash_time = 0.2
var dash_cooldown: bool = false
var is_dashing: bool = false
var dash_direction = Vector2()

var knock_back = false
var knock_back_force = 50000
var enemy_direction = Vector2()

func _ready() -> void:
	life.value = health
	area_daño.connect("body_entered", _on_area_daño_body_entered)

func _physics_process(delta: float) -> void:
	if knock_back:
		var knockback_direction = (global_position - enemy_direction).normalized()
		velocity = knockback_direction * knock_back_force * delta
		move_and_slide()
		await get_tree().create_timer(0.5).timeout
		knock_back = false
	else:
		_move_player(delta)

func _move_player(delta):
	var direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	if direction.x > 0:
		skin.flip_h = false
	elif direction.x < 0:
		skin.flip_h = true
	
	if velocity.x > 0:
		if is_dashing:
			#animation.play("dash")
			pass
		else:
			#animation.play("walk")
			pass
	else:
		#animation.play("idle")
		pass
	
	var weight = delta * (acceleration if direction else 10)
	velocity = lerp(velocity, direction * speed, weight)
	
	# Detectar la acción de Dash
	if Input.is_action_just_pressed("dash") and !dash_cooldown:
		start_dash(direction, delta)
		is_dashing = true
	
	move_and_slide()

func start_dash(direction, delta):
	dash_cooldown = true
	dash_direction = direction.normalized()
	velocity = dash_direction*dash_speed
	velocity *= 1.0 - (8 * delta)
	await get_tree().create_timer(0.3).timeout
	is_dashing = false
	await get_tree().create_timer(0.7).timeout
	dash_cooldown = false

func _health(damage):
	life.value -= damage
	if life.value <= 0:
		pass

func _on_area_daño_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		_health(body.damage)
		knock_back = true
		enemy_direction = body.global_position
