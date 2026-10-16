class_name Tienda
extends Control

# Panel de la tienda. Muestra el recetario repartido en páginas de cartas y deja comprar
# las recetas que todavía no están en el menú de la panadería.
#
# La tienda no cobra ni desbloquea nada por su cuenta. Le pide la compra al Recetario,
# que la valida en el servidor y después avisa a todas las máquinas. Por eso el panel se
# refresca escuchando esa confirmación y no en el momento en que alguien aprieta.

## Cuántas cartas entran en una página. Es también la cantidad de cartas que existen,
## porque al cambiar de página se vuelven a llenar las mismas en vez de crear otras.
const CARTAS_POR_PAGINA: int = 3

## Cuánto queda el globo por encima del ícono al que apunta.
const SEPARACION_DEL_GLOBO: float = 4.0

## Se emite al cerrar el panel, para que quien lo abrió devuelva el control al juego.
signal cerrada

## La escena de carta que se usa para armar la página.
@export var escena_carta: PackedScene

@onready var fila_cartas: HBoxContainer = %Cartas
@onready var dinero_mostrado: Label = %Dinero
@onready var flecha_izquierda: Button = %FlechaIzquierda
@onready var flecha_derecha: Button = %FlechaDerecha
@onready var boton_cerrar: Button = %BotonCerrar
@onready var globo: TextureRect = %Globo
@onready var nombre_del_ingrediente: Label = %NombreIngrediente

var _cartas: Array[CartaReceta] = []
var _pagina: int = 0
var _dinero: int = 0


func _ready() -> void:
	hide()
	_crear_cartas()
	flecha_izquierda.pressed.connect(_ir_a_pagina.bind(-1))
	flecha_derecha.pressed.connect(_ir_a_pagina.bind(1))
	boton_cerrar.pressed.connect(cerrar)
	if Recetario.instance:
		Recetario.instance.receta_comprada.connect(_al_comprarse_una_receta)
	if GameManager.instance:
		_conectar_game_manager()
	else:
		await get_tree().process_frame
		if GameManager.instance:
			_conectar_game_manager()


# Con el panel abierto se consume todo lo que no haya usado la interfaz. Si no, el gato
# seguiría girando la cámara y tomando objetos por detrás del panel.
func _unhandled_input(evento: InputEvent) -> void:
	if not visible:
		return
	if evento.is_action_pressed("ui_cancel"):
		cerrar()
	get_viewport().set_input_as_handled()


func abrir() -> void:
	_pagina = 0
	_esconder_globo()
	show()
	_refrescar()


func cerrar() -> void:
	_esconder_globo()
	hide()
	cerrada.emit()


func _conectar_game_manager() -> void:
	var gestor: GameManager = GameManager.instance
	gestor.money_updated.connect(_al_cambiar_el_dinero)
	_al_cambiar_el_dinero(gestor.dinero_recaudado)


func _al_cambiar_el_dinero(cantidad: int) -> void:
	_dinero = cantidad
	dinero_mostrado.text = "%d" % cantidad
	_refrescar()


# Llega cuando el servidor confirmó una compra, sea de este jugador o de otro.
func _al_comprarse_una_receta(_id_receta: StringName) -> void:
	_refrescar()


# Las cartas se crean una sola vez y se rellenan al cambiar de página. Así no se arman
# y se destruyen nodos cada vez que alguien aprieta una flecha.
func _crear_cartas() -> void:
	for i: int in range(CARTAS_POR_PAGINA):
		var carta: CartaReceta = escena_carta.instantiate()
		fila_cartas.add_child(carta)
		carta.compra_pedida.connect(_al_pedir_compra)
		carta.ingrediente_apuntado.connect(_mostrar_globo)
		carta.ingrediente_soltado.connect(_esconder_globo)
		_cartas.push_back(carta)


func _ir_a_pagina(avance: int) -> void:
	_pagina = clampi(_pagina + avance, 0, maxi(_cantidad_de_paginas() - 1, 0))
	_refrescar()


func _refrescar() -> void:
	var recetario: RecetaSet = _recetas()
	if not is_inside_tree() or recetario == null:
		return
	_esconder_globo()
	for i: int in range(_cartas.size()):
		var carta: CartaReceta = _cartas[i]
		var receta: RecetaDef = recetario.obtener(_pagina * CARTAS_POR_PAGINA + i)
		if receta == null:
			carta.hide()
			continue
		carta.mostrar(receta, recetario.iconos_ingredientes)
		carta.cambiar_estado(_estado_de(receta))
	# Las flechas desaparecen si el recetario cabe en una sola página. En la primera y
	# en la última página la flecha que sobra queda deshabilitada, y como su estilo
	# deshabilitado no dibuja nada, se apaga sin mover de lugar a las cartas.
	var hay_varias_paginas: bool = _cantidad_de_paginas() > 1
	flecha_izquierda.visible = hay_varias_paginas
	flecha_derecha.visible = hay_varias_paginas
	flecha_izquierda.disabled = _pagina <= 0
	flecha_derecha.disabled = _pagina >= _cantidad_de_paginas() - 1


func _estado_de(receta: RecetaDef) -> CartaReceta.Estado:
	if Recetario.instance and Recetario.instance.esta_desbloqueada(receta.id):
		return CartaReceta.Estado.COMPRADA
	if _dinero >= receta.precio_compra:
		return CartaReceta.Estado.DISPONIBLE
	return CartaReceta.Estado.SIN_DINERO


func _cantidad_de_paginas() -> int:
	var recetario: RecetaSet = _recetas()
	if recetario == null or recetario.recetas.is_empty():
		return 1
	return ceili(float(recetario.recetas.size()) / float(CARTAS_POR_PAGINA))


func _recetas() -> RecetaSet:
	if Recetario.instance == null:
		return null
	return Recetario.instance.recetas


# Pone el globo justo encima del ícono apuntado, con la punta mirándolo. Si el ícono
# queda muy al borde, el globo se corre para no salirse de la pantalla.
func _mostrar_globo(nombre_ingrediente: String, zona: Rect2) -> void:
	nombre_del_ingrediente.text = nombre_ingrediente.capitalize()
	globo.show()
	var izquierda: float = zona.get_center().x - globo.size.x * 0.5
	izquierda = clampf(izquierda, 0.0, size.x - globo.size.x)
	globo.global_position = Vector2(izquierda, zona.position.y - globo.size.y - SEPARACION_DEL_GLOBO)


func _esconder_globo() -> void:
	globo.hide()


# La carta solo avisa que la eligieron. Quien decide si la compra se hace es el servidor.
func _al_pedir_compra(receta_elegida: RecetaDef) -> void:
	if Recetario.instance == null:
		return
	Recetario.instance.pedir_compra.rpc(receta_elegida.id)
