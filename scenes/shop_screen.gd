extends Control

@export var item_card_scene: PackedScene
@export var item_data_array: Array[ItemData]
@onready var item_card_container: HBoxContainer = %ItemCardContainer
@onready var item_card_1: ItemCard = %ItemCard1
@onready var item_card_2: ItemCard = %ItemCard2
@onready var item_card_3: ItemCard = %ItemCard3


func _ready() -> void:
	generate_cards()
	item_card_1.bought.connect(_on_bought.bind(item_card_1))
	item_card_2.bought.connect(_on_bought.bind(item_card_2))
	item_card_3.bought.connect(_on_bought.bind(item_card_3))

func generate_cards() -> void:
	if not item_card_scene:
		return
	
	var available_items = item_data_array.duplicate()
	
	for margin_container in item_card_container.get_children():
		var item_card: ItemCard = margin_container.get_child(0)
		
		var random_item = available_items.pick_random()
		item_card.item_data = random_item
		
		available_items.erase(random_item)

func _on_bought(item_card: ItemCard) -> void:
	var available_items = item_data_array.duplicate()
	available_items.erase(item_card)
	item_card.item_data = available_items.pick_random()
	
