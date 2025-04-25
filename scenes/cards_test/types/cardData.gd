extends Resource
class_name CardData

@export var nombre: String
@export_enum("trap", "enemy") var tipo
@export var costo: int
@export var hp: int
@export var daño: int
@export var velocidad: int
@export var icono: String
@export var escala: Vector2 = Vector2(0.5, 0.5)
# Texture NinePatchRect
@export var textura: Texture2D = preload("res://assets/card_container.png")
@export var x: float = 26.0
@export var y: float = 0.0
@export var w: float = 26.0
@export var h: float = 26.0
@export var patch_margin_left: int = 6
@export var patch_margin_top: int = 6
@export var patch_margin_right: int = 6
@export var patch_margin_bottom: int = 6
# Collision Shape
@export_enum("Circle", "Capsule", "Rectange") var colision = 0
@export var radio: float = 0.0
@export var altura: float = 0.0
@export var tamaño: Vector2 = Vector2(0, 0)
@export var posicion_colision: Vector2 = Vector2(0, 0)
