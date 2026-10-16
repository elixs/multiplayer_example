class_name RecetaSet
extends Resource

# El recetario de la panadería: la lista de todo lo que se puede preparar. Se guarda
# como recurso para que la mesa, el HUD y la tienda lean siempre la misma lista y no
# cada uno su propia copia.


## Las recetas disponibles, en el orden en que se muestran al jugador.
@export var recetas: Array[RecetaDef] = []

## Qué dibujo le toca a cada ingrediente. La clave es el mismo nombre_ingrediente que
## usan las recetas y los objetos de la cocina, así que acá queda la lista completa de
## nombres válidos en un solo lugar.
@export var iconos_ingredientes: Dictionary[String, Texture2D] = {}


func obtener(indice: int) -> RecetaDef:
	if indice < 0 or indice >= recetas.size():
		return null
	return recetas[indice]


func buscar_por_id(id: StringName) -> RecetaDef:
	for receta: RecetaDef in recetas:
		if receta and receta.id == id:
			return receta
	return null


# La receta que calza exactamente con los ingredientes que hay sobre la mesa. Devuelve
# null mientras falte algo, sobre algo o la combinación no corresponda a ninguna receta.
func buscar_por_ingredientes(nombres: Array[String]) -> RecetaDef:
	for receta: RecetaDef in recetas:
		if receta and receta.calza_con(nombres):
			return receta
	return null


# Las recetas que todavía se podrían terminar con lo que hay puesto. Sirve para avisarle
# al jugador hacia dónde va su preparación antes de que la complete.
func recetas_posibles(nombres: Array[String]) -> Array[RecetaDef]:
	var posibles: Array[RecetaDef] = []
	for receta: RecetaDef in recetas:
		if receta and receta.admite(nombres):
			posibles.push_back(receta)
	return posibles


# Cuántos ingredientes pide la receta más larga. La mesa lo usa para saber cuántos
# espacios tiene que ofrecer sin que ese número quede escrito a mano en dos lugares.
func maximo_de_ingredientes() -> int:
	var maximo: int = 0
	for receta: RecetaDef in recetas:
		if receta and receta.ingredientes.size() > maximo:
			maximo = receta.ingredientes.size()
	return maximo


func icono_de_ingrediente(nombre: String) -> Texture2D:
	return iconos_ingredientes.get(nombre)
