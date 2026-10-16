class_name CartaReceta
extends Control

# Carta de la tienda. Muestra una receta con su dibujo, la fórmula de ingredientes que
# pide y los dos números que importan: lo que paga el cliente por una unidad y lo que
# cuesta desbloquearla. La misma carta cubre los cuatro estados en que puede aparecer
# una receta, así que la tienda solo cambia el estado y no arma otra carta.
#
# Las dos franjas de abajo se leen distinto a propósito. Arriba va la cara del cliente
# con una moneda pegada al lado, porque ese número es la plata que entra cada vez que le
# venden una unidad. Abajo cuelga una etiqueta de precio, porque ese número es lo que
# cuesta desbloquear la receta. Cuando la receta ya está comprada la etiqueta desaparece
# y la franja queda solo con la insignia, para que no parezca que hay algo que pagar.
#
# La carta está dibujada a 608x980 y acá se muestra a 248x400. Las zonas donde entra
# cada cosa salen de medir esa imagen, por eso los nodos de adentro van anclados en
# proporciones y no en píxeles sueltos.

enum Estado {
	DISPONIBLE, ## La receta se puede comprar ahora mismo.
	SIN_DINERO, ## Se ve entera, pero todavía no alcanza la plata.
	COMPRADA, ## Ya está en el menú de la panadería.
	BLOQUEADA, ## No se muestra el contenido, aparece la carta con candado.
}

## Alto máximo en píxeles de cada ícono de ingrediente dentro de la fórmula. Si la
## receta pide muchos ingredientes, las piezas se achican para caber en la ventana.
const ALTO_ICONO_FORMULA: float = 38.0

## Ancho que tiene la fila de la fórmula cuando la carta se muestra a su tamaño de
## diseño. Se usa mientras el nodo todavía no alcanzó a medirse solo.
const ANCHO_FORMULA_DISENO: float = 170.0

## Los símbolos de más e igual van más chicos que los ingredientes para que la fórmula
## se lea como una frase y no como cinco dibujos del mismo peso.
const PROPORCION_SIMBOLO: float = 0.55

const SEPARACION_FORMULA: int = 4

# Tintes del papel para que la carta responda al mouse igual que los botones del kit.
const TINTE_NORMAL: Color = Color(1.0, 1.0, 1.0)
const TINTE_REALCE: Color = Color(1.06, 1.03, 1.0)
const TINTE_PRESIONADO: Color = Color(0.92, 0.89, 0.86)

# Cuando no alcanza la plata la carta se apaga un poco, sin llegar a esconder el precio.
const TINTE_SIN_DINERO: Color = Color(0.68, 0.66, 0.64)

## Se emite cuando alguien aprieta una carta que se puede comprar.
signal compra_pedida(receta_elegida: RecetaDef)

## Se emite mientras el mouse está sobre un ingrediente de la fórmula. La zona es el
## rectángulo que ocupa ese ícono en pantalla, para poder poner el globo justo encima.
signal ingrediente_apuntado(nombre_ingrediente: String, zona: Rect2)

## Se emite cuando el mouse deja de apuntar a un ingrediente.
signal ingrediente_soltado

## Los dos símbolos que arman la fórmula de ingredientes.
@export var simbolo_mas: Texture2D
@export var simbolo_igual: Texture2D

@onready var nombre: Label = %Nombre
@onready var dibujo_resultado: TextureRect = %Resultado
@onready var formula: HBoxContainer = %Formula
@onready var precio_venta: Label = %PrecioVenta
@onready var precio_compra: Label = %PrecioCompra
@onready var etiqueta_compra: TextureRect = %Etiqueta
@onready var tapa_bloqueada: TextureRect = %Bloqueo
@onready var insignia_comprada: TextureRect = %Insignia
@onready var boton: Button = %Boton

var receta: RecetaDef
var estado: Estado = Estado.DISPONIBLE

# Qué ingrediente representa cada pieza de la fórmula. Los símbolos y el pan del final
# quedan con el nombre vacío porque no tienen nada que mostrar.
var _nombres_de_la_formula: Array[String] = []
var _ingrediente_apuntado: String = ""


func _ready() -> void:
	formula.add_theme_constant_override("separation", SEPARACION_FORMULA)
	boton.mouse_entered.connect(_al_entrar_el_mouse)
	boton.mouse_exited.connect(_al_salir_el_mouse)
	boton.gui_input.connect(_al_recibir_mouse)
	boton.button_down.connect(_al_apretar)
	boton.button_up.connect(_al_soltar)
	boton.pressed.connect(_al_elegir)


# Llena la carta con una receta. Los dibujos de los ingredientes vienen de afuera porque
# el recetario es el único lugar donde se guarda qué dibujo le toca a cada nombre.
func mostrar(nueva_receta: RecetaDef, iconos_ingredientes: Dictionary) -> void:
	receta = nueva_receta
	if receta == null:
		hide()
		return
	show()
	nombre.text = receta.nombre
	dibujo_resultado.texture = receta.icono
	precio_venta.text = "$%d" % receta.precio_venta
	precio_compra.text = "$%d" % receta.precio_compra
	_armar_formula(iconos_ingredientes)
	cambiar_estado(estado)


func cambiar_estado(nuevo_estado: Estado) -> void:
	estado = nuevo_estado
	tapa_bloqueada.visible = estado == Estado.BLOQUEADA
	insignia_comprada.visible = estado == Estado.COMPRADA
	# Las recetas que la panadería ya sabe hacer desde el primer día no tienen precio de
	# compra, así que la franja de abajo se vacía igual que cuando ya se compraron.
	var queda_por_pagar: bool = estado != Estado.COMPRADA and receta != null and receta.precio_compra > 0
	etiqueta_compra.visible = queda_por_pagar
	boton.disabled = estado != Estado.DISPONIBLE
	if estado == Estado.SIN_DINERO:
		modulate = TINTE_SIN_DINERO
	else:
		modulate = TINTE_NORMAL


# Arma la fila ingrediente más ingrediente igual pan. Un ingrediente sin dibujo se salta,
# así la carta sigue sirviendo mientras no existan todos los íconos.
func _armar_formula(iconos_ingredientes: Dictionary) -> void:
	_vaciar_formula()
	var dibujos: Array[Texture2D] = []
	var nombres: Array[String] = []
	for nombre_ingrediente: String in receta.ingredientes:
		var dibujo: Texture2D = iconos_ingredientes.get(nombre_ingrediente)
		if dibujo != null:
			dibujos.push_back(dibujo)
			nombres.push_back(nombre_ingrediente)
	if dibujos.is_empty():
		return
	var lado: float = _lado_de_pieza(dibujos.size())
	for i: int in range(dibujos.size()):
		if i > 0:
			_sumar_pieza(simbolo_mas, lado * PROPORCION_SIMBOLO, "")
		_sumar_pieza(dibujos[i], lado, nombres[i])
	_sumar_pieza(simbolo_igual, lado * PROPORCION_SIMBOLO, "")
	_sumar_pieza(receta.icono, lado, "")


# Cuánto puede medir cada ícono para que la fórmula entera entre en la ventana. Una
# receta de dos ingredientes son cinco piezas y una de tres son siete, así que el
# tamaño sale de repartir el ancho disponible y no de un número fijo.
func _lado_de_pieza(cantidad_ingredientes: int) -> float:
	var ancho: float = formula.size.x
	if ancho <= 0.0:
		ancho = ANCHO_FORMULA_DISENO
	var piezas_grandes: float = float(cantidad_ingredientes + 1)
	var piezas_chicas: float = float(cantidad_ingredientes)
	var separaciones: float = float(cantidad_ingredientes * 2 * SEPARACION_FORMULA)
	var lado: float = (ancho - separaciones) / (piezas_grandes + piezas_chicas * PROPORCION_SIMBOLO)
	return minf(lado, ALTO_ICONO_FORMULA)


# Los hijos se sacan del árbol antes de liberarlos porque queue_free recién actúa al
# final del cuadro y si no la fila quedaría con las piezas viejas encima de las nuevas.
func _vaciar_formula() -> void:
	_nombres_de_la_formula.clear()
	for pieza: Node in formula.get_children():
		formula.remove_child(pieza)
		pieza.queue_free()


# Agrega una pieza a la fórmula y anota a qué ingrediente corresponde, para saber
# después qué nombre mostrar cuando el mouse pase sobre ella.
func _sumar_pieza(dibujo: Texture2D, lado: float, nombre_ingrediente: String) -> void:
	formula.add_child(_crear_pieza(dibujo, lado))
	_nombres_de_la_formula.push_back(nombre_ingrediente)


func _crear_pieza(dibujo: Texture2D, lado: float) -> TextureRect:
	var pieza: TextureRect = TextureRect.new()
	pieza.texture = dibujo
	pieza.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	pieza.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pieza.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pieza.custom_minimum_size = Vector2(lado, lado)
	return pieza


func _al_entrar_el_mouse() -> void:
	if estado == Estado.DISPONIBLE:
		modulate = TINTE_REALCE


func _al_salir_el_mouse() -> void:
	if estado == Estado.DISPONIBLE:
		modulate = TINTE_NORMAL
	_soltar_el_ingrediente()


# Revisa sobre qué ícono de la fórmula está el mouse. Se avisa hacia afuera en vez de
# dibujar el globo acá, para que la tienda tenga uno solo y no uno por carta.
func _al_recibir_mouse(evento: InputEvent) -> void:
	var movimiento: InputEventMouseMotion = evento as InputEventMouseMotion
	if movimiento == null:
		return
	# El evento llega con la posición medida dentro del botón, así que hay que llevarla a
	# coordenadas de pantalla para compararla con los íconos de la fórmula.
	var raton: Vector2 = boton.get_global_transform() * movimiento.position
	for i: int in range(formula.get_child_count()):
		if _nombres_de_la_formula[i].is_empty():
			continue
		var pieza: Control = formula.get_child(i)
		if not pieza.get_global_rect().has_point(raton):
			continue
		if _nombres_de_la_formula[i] != _ingrediente_apuntado:
			_ingrediente_apuntado = _nombres_de_la_formula[i]
			ingrediente_apuntado.emit(_ingrediente_apuntado, pieza.get_global_rect())
		return
	_soltar_el_ingrediente()


func _soltar_el_ingrediente() -> void:
	if _ingrediente_apuntado.is_empty():
		return
	_ingrediente_apuntado = ""
	ingrediente_soltado.emit()


func _al_apretar() -> void:
	if estado == Estado.DISPONIBLE:
		modulate = TINTE_PRESIONADO


func _al_soltar() -> void:
	if estado == Estado.DISPONIBLE:
		modulate = TINTE_NORMAL


func _al_elegir() -> void:
	if estado == Estado.DISPONIBLE and receta != null:
		compra_pedida.emit(receta)
