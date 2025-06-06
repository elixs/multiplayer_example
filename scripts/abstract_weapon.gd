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
	print("charge " + str(charge_power))
	var bullet:proyectile = bullet_scene.instantiate() 
	bullet.visible = false

	overcharge_sprite.visible = false
	bullet.set_multiplayer_authority(multiplayer.get_unique_id())
	bullet.pos_spawn = $Marker2D.global_position
	#print(get_parent().rotation)
	bullet.rotacion_spawn = get_parent().global_rotation
	bullet.speed = charge_power * bullet.speed * 2+1000
	get_parent().get_parent().get_parent().add_child(bullet,true)

	is_overcharged = false
	bullet.visible = true
	var scala2 = Vector2(1.0+charge_power * 2.0 ,1.0+charge_power*2.0)
	bullet.animation.scale = scala2
	bullet.zona_colision.scale = scala2


@rpc("authority","call_local")
func begin_charge():
	playback.travel("charge")
func overcharge():
	overcharge_sprite.visible = true
	is_overcharged = true
	 
