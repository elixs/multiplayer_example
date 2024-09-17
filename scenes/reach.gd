extends Hitbox



# Called when the node enters the scene tree for the first time.
func _ready():
	id = get_tree().get_multiplayer().get_unique_id()
	set_multiplayer_authority(id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

