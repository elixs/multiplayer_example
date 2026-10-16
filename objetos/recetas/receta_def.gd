class_name RecetaDef
extends Resource

# Una receta de la panadería. Igual que los emotes, las recetas se describen como datos
# y no como código, así que agregar un pan nuevo es llenar una ficha en el inspector.
# La lista de ingredientes es lo único que decide si una preparación calza, por lo que
# los nombres tienen que escribirse igual que en nombre_ingrediente de cada Ingrediente.

## Identificador corto que viaja por la red cuando alguien prepara o vende esta receta.
@export var id: StringName = &""

## Nombre que se le muestra al jugador en la carta de receta y en la tienda.
@export var nombre: String = ""

## Qué ingredientes pide la receta. El orden no importa, pero sí cuántas veces aparece
## cada uno, así que una receta con dos harinas se escribe con "harina" repetido.
@export var ingredientes: Array[String] = []

## Dibujo del pan terminado. Se usa en la carta de receta, en el HUD y en la tienda.
@export var icono: Texture2D

## Escena del pan que aparece sobre la mesa al terminar la preparación. Mientras el
## modelo no exista se deja vacía y la receta solo se resuelve como dato.
@export var resultado: PackedScene

## Cuántas monedas deja vender una unidad de esta receta.
@export var precio_venta: int = 0

## Cuánto cuesta desbloquear la receta en la tienda. Las recetas que la panadería ya
## sabe hacer desde el primer día no se compran, así que ahí este número no se usa.
@export var precio_compra: int = 0

## Si la panadería ya sabe hacer esta receta cuando empieza la partida. Las demás
## aparecen con candado en la tienda hasta que alguien las compre.
@export var disponible_al_inicio: bool = false

## Cuántos segundos tarda la mesa en convertir los ingredientes en el pan.
@export var segundos_preparacion: float = 3.0


func tiene_resultado() -> bool:
	return resultado != null


# Revisa si lo que hay sobre la mesa es exactamente esta receta. Compara contando
# repeticiones y no solo presencia, para que "dos harinas" no calce con "una harina".
func calza_con(nombres: Array[String]) -> bool:
	if nombres.size() != ingredientes.size():
		return false
	return _contar(nombres) == _contar(ingredientes)


# Revisa si lo que hay sobre la mesa todavía puede terminar en esta receta, es decir
# si cada ingrediente puesto aparece en la receta al menos esa misma cantidad de veces.
func admite(nombres: Array[String]) -> bool:
	if nombres.size() > ingredientes.size():
		return false
	var puestos: Dictionary = _contar(nombres)
	var pedidos: Dictionary = _contar(ingredientes)
	for nombre: String in puestos:
		if puestos[nombre] > pedidos.get(nombre, 0):
			return false
	return true


# Cuántas veces aparece cada nombre en la lista.
static func _contar(nombres: Array[String]) -> Dictionary:
	var cuenta: Dictionary = {}
	for nombre: String in nombres:
		cuenta[nombre] = cuenta.get(nombre, 0) + 1
	return cuenta
