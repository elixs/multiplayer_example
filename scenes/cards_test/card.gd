extends Node2D

@export var datos: CardData

@onready var _item: Sprite2D = $Skin/Skin
@onready var _name: Label = $Name
@onready var _damage: Label = $Damage
@onready var _life: Label = $Life
@onready var _coste: Label = $Coste
@onready var nine_patch: NinePatchRect = $Skin/NinePatchRect
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	_item.texture = load(datos.icono)
	_name.text = datos.nombre
	_damage.text = str(datos.daño)
	_life.text = str(datos.hp)
	if datos.nombre == "Box":
		_life.text = "∞"
	_coste.text = str(datos.costo)
	scale = datos.escala
	# Nine patch rect
	nine_patch.texture = datos.textura
	nine_patch.region_rect = Rect2(datos.x, datos.y, datos.w, datos.h)
	nine_patch.patch_margin_left = datos.patch_margin_left
	nine_patch.patch_margin_top = datos.patch_margin_top
	nine_patch.patch_margin_right = datos.patch_margin_right
	nine_patch.patch_margin_bottom = datos.patch_margin_bottom
