class_name  ItemCard
extends PanelContainer

signal bought

@onready var display_name: Label = %DisplayName
@onready var image: TextureRect = %Image
@onready var description: RichTextLabel = %Description
@onready var price: Label = %Price


@export var item_data: ItemData:
	set(value):
		item_data = value
		update()
		

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func update() -> void:
	if not is_node_ready():
		return
	display_name.text = item_data.display_name
	image.texture = item_data.image
	description.text = item_data.description
	price.text = "Price: " + str(item_data.price) + " Dung"
	
func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var player_coins: int = Game.get_current_player_dung()
		if player_coins >= item_data.price:
			Game.set_current_player_dung(player_coins-item_data.price)
			var player: Player = Game.get_current_player().scene
			item_data.action(player)
			bought.emit()
