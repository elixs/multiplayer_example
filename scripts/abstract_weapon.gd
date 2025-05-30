extends Node2D
var bullet_path:String
@export var type_bullet:String = 'boomerang'
@onready var bullet_scene = load("res://scenes/projectiles/bullet_"+type_bullet+".tscn")
@onready var sprite_base = $SpriteBase
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var bullet_force = 0
@export var is_overcharged = false
@onready var overcharge_sprite = $overcharge_sprite

@rpc("authority","call_local","reliable")
func shoot(charge_power):
	playback.travel("idle")
	var bullet:proyectile = bullet_scene.instantiate() 
	overcharge_sprite.visible = false
	bullet.set_multiplayer_authority(multiplayer.get_unique_id())
	bullet.pos_spawn = $Marker2D.global_position
	#print(get_parent().rotation)
	bullet.rotacion_spawn = get_parent().global_rotation
	bullet.speed = charge_power * bullet.speed
	get_parent().get_parent().get_parent().add_child(bullet,true)
	if is_overcharged:
		var scala = Vector2(3.0,3.0)
		bullet.animation.scale = scala
		bullet.zona_colision.scale = scala
	is_overcharged = false

@rpc("authority","call_local")
func begin_charge():
	playback.travel("charge")
func overcharge():
	overcharge_sprite.visible = true
	is_overcharged = true
	 
