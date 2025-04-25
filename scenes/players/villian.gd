extends Node2D

@onready var enemies_node: Node2D = $"../../Enemies"
var enemy_scene: PackedScene = preload("res://scenes/enemies/enemy.tscn")
@onready var progress_bar: ProgressBar = $TextureProgressBar
var fill_time = 36.0 # segundos

var card_dragged
var result

func _ready() -> void:
	if Game.players[1].role == 2:
		set_multiplayer_authority(Game.players[1].id)
		if multiplayer.get_unique_id() == 1:
			visible = false
	else:
		set_multiplayer_authority(Game.players[0].id)
		if multiplayer.get_unique_id() != 1:
			visible = false

var tmp_card = null
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = _check_for_card()
			if card:
				if card == tmp_card:
					card_dragged.scale = Vector2(0.5, 0.5)
					tmp_card = null
					card = null
					card_dragged = null
				else:
					if tmp_card:
						tmp_card.scale = Vector2(0.5, 0.5)
					card_dragged = card
					tmp_card = card
					card_dragged.scale = Vector2(0.55, 0.55)
			else:
				if card_dragged:
					if result.size() < 1 and card_dragged.datos.costo*10 <= progress_bar.value:
						_spawn_enemy.rpc(
							card_dragged.datos.velocidad,
							card_dragged.datos.hp,
							card_dragged.datos.daño,
							card_dragged.datos.icono,
							card_dragged.datos.tipo,
							card_dragged.datos.colision,
							card_dragged.datos.radio,
							card_dragged.datos.altura,
							card_dragged.datos.tamaño,
							card_dragged.datos.posicion_colision,
							get_global_mouse_position())
						card_dragged.scale = Vector2(0.5, 0.5)
						progress_bar.value -= card_dragged.datos.costo*10
						tmp_card = null
						card = null
						card_dragged = null
					else:
						card_dragged.scale = Vector2(0.5, 0.5)
						tmp_card = null
						card = null
						card_dragged = null

func _process(_delta):
	if progress_bar.value < progress_bar.max_value:
		progress_bar.value += (progress_bar.max_value / fill_time) * 0.05

@rpc("call_local","reliable")
func _spawn_enemy(velocidad: int, hp: int, daño: int, icono: String, tipo: int, colision: int, radio: float, altura: float, tamaño: Vector2, pos_colision: Vector2, mouse_pos: Vector2):
	var enemy_inst = enemy_scene.instantiate()
	enemy_inst.set_multiplayer_authority(1)
	enemy_inst.position = mouse_pos
	enemies_node.add_child(enemy_inst, true)
	enemy_inst.setup(velocidad, hp, daño, icono, tipo, colision, radio, altura, tamaño, pos_colision) # o asignás stats manualmente

func _check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collide_with_bodies = true
	parameters.collision_mask = 3
	result = space_state.intersect_point(parameters)
	print(result)
	if result.size() > 0:
		var hay_colision = false
		for colision in result:
			if colision["collider"] is StaticBody2D or colision["collider"] is CharacterBody2D:
				hay_colision = true
				break
		#var staticbody = result[0]["collider"] is not StaticBody2D
		#var characterbody = result[0]["collider"] is not CharacterBody2D
		if !hay_colision:
			return result[0].collider.get_parent()
	return null
