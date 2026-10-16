class_name CierreDeDia
extends Control

# Panel que resume la jornada cuando se acaba el día. Muestra en qué día va la panadería,
# cuántas estrellas se ganó, las cifras del día y un sello según si llegó o no a la meta.
#
# El panel no calcula nada del juego. Recibe los números ya hechos y solo decide cómo se
# ven, así que quien lleve la cuenta de la jornada puede cambiar sin tocar esta pantalla.

## Cuántas veces la meta hay que ganar para cada estrella. La primera estrella es
## cumplir la meta y las otras dos son superarla.
const VECES_LA_META_POR_ESTRELLA: Array[float] = [1.0, 1.5, 2.0]

## Se emite cuando el jugador aprieta seguir.
signal continuado

@export var dibujo_estrella_llena: Texture2D
@export var dibujo_estrella_vacia: Texture2D
@export var dibujo_sello_exito: Texture2D
@export var dibujo_sello_fracaso: Texture2D
@export var dibujo_monedas: Texture2D
@export var dibujo_clientes: Texture2D
@export var dibujo_panes: Texture2D
@export var dibujo_clientes_perdidos: Texture2D

@onready var titulo: Label = %Titulo
@onready var meta_mostrada: Label = %Meta
@onready var estrellas: HBoxContainer = %Estrellas
@onready var filas: VBoxContainer = %Filas
@onready var sello: TextureRect = %Sello
@onready var boton_seguir: Button = %BotonSeguir


func _ready() -> void:
	hide()
	boton_seguir.pressed.connect(_al_seguir)


# Con el panel abierto se consume lo que no haya usado la interfaz, para que el gato no
# siga moviendo la cámara por detrás.
func _unhandled_input(_evento: InputEvent) -> void:
	if visible:
		get_viewport().set_input_as_handled()


# Muestra el resumen de la jornada. La meta es el dinero que había que juntar, y de
# compararla con lo ganado salen las estrellas y el sello.
func mostrar(numero_de_dia: int, monedas: int, clientes: int, panes: int, perdidos: int, meta: int) -> void:
	titulo.text = "Día %d" % numero_de_dia
	meta_mostrada.text = "Meta del día: %d" % meta
	var ganadas: int = _estrellas_ganadas(monedas, meta)
	_pintar_estrellas(ganadas)
	sello.texture = dibujo_sello_exito if ganadas > 0 else dibujo_sello_fracaso
	var lineas: Array[FilaEstadistica] = []
	for hijo: Node in filas.get_children():
		lineas.push_back(hijo as FilaEstadistica)
	lineas[0].mostrar(dibujo_monedas, "Monedas del día", monedas)
	lineas[1].mostrar(dibujo_clientes, "Clientes atendidos", clientes)
	lineas[2].mostrar(dibujo_panes, "Panes entregados", panes)
	lineas[3].mostrar(dibujo_clientes_perdidos, "Clientes que se fueron", perdidos)
	show()
	boton_seguir.grab_focus()


func cerrar() -> void:
	hide()


func _estrellas_ganadas(monedas: int, meta: int) -> int:
	if meta <= 0:
		return VECES_LA_META_POR_ESTRELLA.size()
	var ganadas: int = 0
	for veces: float in VECES_LA_META_POR_ESTRELLA:
		if float(monedas) >= float(meta) * veces:
			ganadas += 1
	return ganadas


func _pintar_estrellas(ganadas: int) -> void:
	for i: int in range(estrellas.get_child_count()):
		var estrella: TextureRect = estrellas.get_child(i)
		estrella.texture = dibujo_estrella_llena if i < ganadas else dibujo_estrella_vacia


func _al_seguir() -> void:
	cerrar()
	continuado.emit()
