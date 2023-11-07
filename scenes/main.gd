class_name Main
extends Node2D

@export var mesero_scene: PackedScene
@export var chef_scene : PackedScene
@onready var players: Node2D = $Players
@onready var spawn: Node2D = $Spawn
@onready var meta = $Meta/meta
@export var meta_dia = 50
@onready var countdown = $countdown 
var ganancias = 0
@onready var mesa_ing = $mesaIng
# @onready var tocomple = $mesaIng/tocomple
@onready var cliente = $cliente
var packed_tocomple = preload("res://scenes/tocomple.tscn")

@onready var tocomple = mesa_ing.get_tocomple()[0]

func _ready() -> void:
	Game.players.sort_custom(func (a, b): return a.id < b.id)
	for i in Game.players.size():
		var player_data = Game.players[i]
		
		if player_data.role == 1:
			var player = chef_scene.instantiate()
			players.add_child(player)
			player.setup(player_data)
			player.global_position = spawn.get_child(0).global_position
		elif player_data.role == 2:
			var player = mesero_scene.instantiate()
			players.add_child(player)
			player.setup(player_data)
			player.global_position = spawn.get_child(1).global_position
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	meta.text = "$"+str(ganancias)+" / $"+str(meta_dia)
	var t = countdown.get_child(0).get_child(0)
	
	if tocomple.come == true:
		ganancias = 50
	if t.minutes == 0 and t.seconds == 0:
			if ganancias < meta_dia:
				get_tree().change_scene_to_file("res://scenes/perder_menu.tscn")
			else:
				get_tree().change_scene_to_file("res://scenes/Victoria-menu.tscn")
