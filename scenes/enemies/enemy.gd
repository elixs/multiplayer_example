extends CharacterBody2D

@onready var player: CharacterBody2D = $"../../Hero"
@onready var skin: Sprite2D = $Skin
@onready var collision: Area2D = $Collision
@onready var life: ProgressBar = $Life
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var collision_shape: CollisionShape2D = $Collision/Collision_body

@export var datos: CardData

@onready var players: Node2D = $"../../Players"
@onready var area: Area2D = $Collision
@onready var area_collision: CollisionShape2D = $Collision/Collision_body
@onready var timer: Timer = $Navigation_timer

var type = 1 #Enemy y 0 Trap
var health: int = 100
var damage: int = 10
var speed: int = 15000
var knock_back = false
var enemy_direction = Vector2()
var figura_coll: Shape2D

func _ready() -> void:
	area.connect("area_entered", _on_collision_area_entered)
	timer.connect("timeout", _on_timer_timeout)
	nav_agent.target_position = players.get_child(0).global_position
	life.value = health


func _physics_process(delta: float) -> void:
	if type == 1 and !nav_agent.is_target_reached():
		var target_pos = nav_agent.get_next_path_position()
		var dir = (target_pos - global_position).normalized()
		if dir.x > 0:
			skin.flip_h = false
		else:
			skin.flip_h = true
		
		if knock_back:
			var knockback_direction = (global_position - enemy_direction).normalized()
			velocity = knockback_direction * 25000 * delta
			move_and_slide()
			_send_data.rpc(position, skin.flip_h, life.value)
			await get_tree().create_timer(0.5).timeout
			knock_back = false
		else:
			if is_multiplayer_authority():
				velocity = dir * speed * delta
				move_and_slide()
				_send_data.rpc(position, skin.flip_h, life.value)


func setup(velocidad: int, hp: int, daño: int, icono: String, tipo: int, colision: int, radio: float, altura: float, tamaño: Vector2, pos_colision: Vector2):
	health = hp
	damage = daño
	speed = velocidad
	skin.texture = load(icono)
	life.max_value = health
	life.value = health
	type = tipo
	if type == 0: #Podríamos eliminar la barra, el navegation agent y el timer
		life.visible = false
	if colision == 0:
		figura_coll = CircleShape2D.new()
		figura_coll.radius = radio
	elif colision == 1:
		figura_coll = CapsuleShape2D.new()
		figura_coll.radius = radio
		figura_coll.height = altura
	else:
		figura_coll = RectangleShape2D.new()
		figura_coll.size = tamaño
	collision_shape.shape = figura_coll
	area_collision.shape = figura_coll
	collision.position = pos_colision
	area_collision.position = pos_colision



@rpc("unreliable_ordered")
func _send_data(pos: Vector2, flip: bool, hp: float) -> void:
	position = lerp(position, pos, 0.5)
	skin.flip_h = flip
	life.value = hp
	if life.value <= 0:
		queue_free()

func _health(_damage):
	life.value -= _damage
	if life.value <= 0:
		queue_free()

func _on_collision_area_entered(_area: Area2D) -> void:
	if _area.is_in_group("hero") and type != 0:
		_health(_area.damage)
		knock_back = true
		enemy_direction = _area.global_position

func _on_timer_timeout() -> void:
	nav_agent.target_position = players.get_child(0).global_position
	timer.start()
