class_name Recetario
extends Node

# Qué recetas sabe hacer la panadería y quién las desbloquea. Vive como autoload porque
# la tienda, la cocina y el HUD necesitan la misma respuesta en todas las máquinas.
#
# La compra siempre la decide el servidor. Cualquier jugador la pide, el servidor revisa
# que la receta exista, que no esté comprada y que alcance la plata, recién ahí cobra y
# avisa a todos. Así dos gatos que aprietan la misma carta al mismo tiempo no la compran
# dos veces ni dejan el dinero en negativo.

static var instance: Recetario

## Todas las recetas de la panadería, compradas o no.
@export var recetas: RecetaSet

## Se emite en todas las máquinas cuando una receta pasa a formar parte del menú.
signal receta_comprada(id_receta: StringName)

var _desbloqueadas: Array[StringName] = []


func _ready() -> void:
	if instance == null:
		instance = self
	else:
		queue_free()
		return
	_desbloquear_las_de_fabrica()


func esta_desbloqueada(id_receta: StringName) -> bool:
	return id_receta in _desbloqueadas


## Copia de las recetas que la panadería ya sabe hacer. Se entrega copiada para que nadie
## de afuera pueda desbloquear una receta sin pasar por la compra.
func desbloqueadas() -> Array[StringName]:
	return _desbloqueadas.duplicate()


# La receta que calza con lo que hay sobre la mesa, pero solo entre las que ya se saben
# hacer. La cocina la puede usar para no dejar preparar algo que todavía no se compró.
func buscar_desbloqueada(nombres_de_ingredientes: Array[String]) -> RecetaDef:
	if recetas == null:
		return null
	var receta: RecetaDef = recetas.buscar_por_ingredientes(nombres_de_ingredientes)
	if receta == null or not esta_desbloqueada(receta.id):
		return null
	return receta


# Lo llama la tienda cuando alguien aprieta una carta. Cualquiera puede pedirla, pero el
# cuerpo solo corre en el servidor, que es el único que ve el dinero de verdad.
@rpc("any_peer", "call_local", "reliable")
func pedir_compra(id_receta: StringName) -> void:
	if not multiplayer.is_server():
		return
	if recetas == null:
		return
	var receta: RecetaDef = recetas.buscar_por_id(id_receta)
	if receta == null:
		return
	if esta_desbloqueada(id_receta):
		return
	var gestor: GameManager = GameManager.instance
	if gestor == null or gestor.dinero_recaudado < receta.precio_compra:
		return
	gestor.quitar_dinero(receta.precio_compra)
	confirmar_compra.rpc(id_receta)


@rpc("authority", "call_local", "reliable")
func confirmar_compra(id_receta: StringName) -> void:
	if esta_desbloqueada(id_receta):
		return
	_desbloqueadas.push_back(id_receta)
	receta_comprada.emit(id_receta)


func _desbloquear_las_de_fabrica() -> void:
	if recetas == null:
		return
	for receta: RecetaDef in recetas.recetas:
		if receta and receta.disponible_al_inicio:
			_desbloqueadas.push_back(receta.id)
