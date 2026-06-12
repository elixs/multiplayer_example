extends Node2D

@export var world: TileMapLayer
@export var resource_scenes: Array[PackedScene]
var possible_positions = []
var occupied_positions = {}

func _ready():
	randomize()
	get_valid_tiles()

	if multiplayer.is_server():
		var timer = Timer.new()
		timer.wait_time = 1
		timer.autostart = true
		timer.timeout.connect(spawn_resource)
		add_child(timer)

func get_valid_tiles():
	var cells = world.get_used_cells()
	for cell in cells:
		possible_positions.append(cell)

func spawn_resource():
	if possible_positions.is_empty():
		return

	var attempts = 20

	while attempts > 0:
		var random_cell = possible_positions.pick_random()
		
		var random_resource = range(resource_scenes.size()).pick_random()
		
		if not occupied_positions.has(random_cell):
			occupied_positions[random_cell] = true 
			
			# El host le dice a TODOS que spawneen
			spawn_resource_rpc.rpc(random_cell,random_resource)

			return

		attempts -= 1


@rpc("authority", "call_local")
func spawn_resource_rpc(cell: Vector2i, random_resource:int):

	var resource_world = resource_scenes[random_resource].instantiate()
	
	resource_world.position = world.map_to_local(cell)

	add_child(resource_world, true)
	
	if multiplayer.is_server():
		resource_world.tree_exited.connect(func():
				occupied_positions.erase(cell)
				)
