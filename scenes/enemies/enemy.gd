extends CharacterBody2D

@onready var player: CharacterBody2D = $"../../Hero"
@onready var skin: Sprite2D = $Skin
@onready var collision: Area2D = $Collision
@onready var life: ProgressBar = $Life
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var timer: Timer = $Timer

@export var health: int = 100
@export var damage: int = 10
@export var speed: int = 15000
var knock_back = false

func _ready() -> void:
	collision.connect("area_entered", _on_collision_area_entered)
	life.value = health
	nav_agent.target_position = player.global_position

func _physics_process(delta: float) -> void:
	if !nav_agent.is_target_reached():
		var target_pos = nav_agent.get_next_path_position()
		var dir = (target_pos - global_position).normalized()
		
		if dir.x > 1:
			skin.flip_h = false
		else:
			skin.flip_h = true
		#
		if !knock_back:
			velocity = dir * speed * delta
			move_and_slide()
		else:
			var knockback_direction = (global_position - player.global_position).normalized()
			velocity = knockback_direction * 50000 * delta
			move_and_slide()
			await get_tree().create_timer(0.5).timeout
			knock_back = false
		

func _health(damage):
	life.value -= damage
	if life.value <= 0:
		queue_free()

func _on_collision_area_entered(area: Area2D) -> void:
	if area.is_in_group("hero"):
		_health(area.damage)
		knock_back = true

func _on_timer_timeout() -> void:
	nav_agent.target_position = player.global_position
	timer.start()
