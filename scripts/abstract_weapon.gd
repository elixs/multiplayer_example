extends Node2D
var bullet_path:String
@export var type_bullet:String = 'boomerang'
@onready var bullet_scene = load("res://scenes/projectiles/bullet_"+type_bullet+".tscn")
@onready var sprite_base = $SpriteBase
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var bullet_force = 0
@rpc("authority","call_local","reliable")
func shoot():
	var bullet = bullet_scene.instantiate() 
	bullet.pos_spawn = $Marker2D.global_position
	#print(get_parent().rotation)
	bullet.rotacion_spawn = get_parent().global_rotation
	get_parent().get_parent().get_parent().add_child(bullet,true)
func charge():
	print("charge")
	playback.travel("charge")
	 
