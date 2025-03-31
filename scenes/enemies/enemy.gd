extends CharacterBody2D

@onready var player: CharacterBody2D = $"../../Hero"
@onready var skin: Sprite2D = $Skin
@onready var collision: Area2D = $Collision
@onready var life: ProgressBar = $Life

@export var health: int = 100
@export var damage: int = 10
@export var speed: int = 500
var knock_back = false

func _ready() -> void:
	life.value = health
	collision.connect("area_entered", _on_collision_area_entered)

func _process(delta):
	if player:
		# Obtener la dirección hacia el jugador
		var direction = (player.global_position - global_position).normalized()
		
		if direction.x > 1:
			skin.flip_h = false
		else:
			skin.flip_h = true
		
		if !knock_back:
			global_position += direction * speed * delta
		else:
			global_position -= direction * speed * delta
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
