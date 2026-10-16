class_name GloboPedido
extends Node3D

# Globo que le sale al cliente sobre la cabeza. Mientras no lo atienden muestra una
# interrogación, y cuando alguien le pregunta qué quiere aparece el dibujo del pan.
# Debajo va la barra de paciencia, que se vacía y cambia de color a medida que se cansa,
# y al lado una carita que muestra cómo se va poniendo.
#
# El globo entero gira para quedar siempre de frente a la cámara de este jugador, en vez
# de que cada dibujo mire por su cuenta. Así todo lo de adentro se acomoda como si fuera
# una pantalla plana y la barra puede vaciarse de derecha a izquierda sin torcerse.

## Alto en unidades de mundo que ocupa el dibujo del pan. El tamaño de pixel se calcula
## a partir de esto, para que todos los panes se vean del mismo porte aunque sus dibujos
## tengan tamaños distintos.
const ALTO_DEL_DIBUJO: float = 0.26

## Alto en unidades de mundo de la carita del cliente que va al lado del globo.
const ALTO_DE_LA_REACCION: float = 0.36

## Cuántos segundos se queda la carita contenta cuando al cliente le entregan su pan.
const SEGUNDOS_DE_CELEBRACION: float = 1.2

# Colores de la barra segun lo que le queda de paciencia al cliente.
const COLOR_TRANQUILO: Color = Color(0.4313726, 0.56078434, 0.33333334)
const COLOR_APURADO: Color = Color(0.8784314, 0.5921569, 0.22745098)
const COLOR_ENOJADO: Color = Color(0.6117647, 0.18431373, 0.13333334)

## Debajo de esta fracción de paciencia la barra se pone naranja, y más abajo roja.
const PACIENCIA_APURADO: float = 0.5
const PACIENCIA_ENOJADO: float = 0.25

## Las caritas con que el cliente va mostrando cómo se siente mientras espera.
@export var dibujo_esperando: Texture2D
@export var dibujo_enojado: Texture2D
@export var dibujo_feliz: Texture2D

@onready var fondo: Sprite3D = $Fondo
@onready var reaccion: Sprite3D = $Reaccion
@onready var dibujo: Sprite3D = $Dibujo
@onready var interrogacion: Label3D = $Interrogacion
@onready var paciencia: Node3D = $Paciencia
@onready var barra_relleno: Node3D = $Paciencia/Pivote
@onready var dibujo_del_relleno: Sprite3D = $Paciencia/Pivote/Relleno


func _ready() -> void:
	esconder()


func _process(_delta: float) -> void:
	if not visible:
		return
	var camara: Camera3D = get_viewport().get_camera_3d()
	if camara == null:
		return
	# Se gira solo en el eje vertical para que el globo quede de frente sin inclinarse.
	# look_at deja la espalda mirando a la cámara, así que después se da vuelta.
	var hacia: Vector3 = camara.global_position
	hacia.y = global_position.y
	if hacia.is_equal_approx(global_position):
		return
	look_at(hacia, Vector3.UP)
	rotate_object_local(Vector3.UP, PI)


func esconder() -> void:
	hide()


# Pone una carita al lado del globo y la deja del mismo porte sea cual sea su dibujo.
func _mostrar_reaccion(cara: Texture2D) -> void:
	if cara == null:
		reaccion.hide()
		return
	reaccion.texture = cara
	reaccion.pixel_size = ALTO_DE_LA_REACCION / float(cara.get_height())
	reaccion.show()


## El cliente está esperando pero todavía no le preguntaron qué quiere.
func mostrar_incognita() -> void:
	show()
	dibujo.hide()
	interrogacion.show()
	_mostrar_reaccion(dibujo_esperando)


## Ya le preguntaron, así que el globo muestra el pan que pidió.
func mostrar_receta(dibujo_del_pan: Texture2D) -> void:
	show()
	interrogacion.hide()
	if dibujo_del_pan == null:
		dibujo.hide()
		return
	dibujo.texture = dibujo_del_pan
	dibujo.pixel_size = ALTO_DEL_DIBUJO / float(dibujo_del_pan.get_height())
	dibujo.show()


## Cuánta paciencia le queda, de 1 a 0. La barra se vacía de derecha a izquierda y va
## cambiando de color, y la carita pasa de esperando a enojado, para que se note sin
## tener que leer la barra.
func mostrar_paciencia(fraccion: float) -> void:
	var avance: float = clampf(fraccion, 0.0, 1.0)
	paciencia.visible = true
	barra_relleno.visible = avance > 0.0
	barra_relleno.scale.x = avance
	if avance <= PACIENCIA_ENOJADO:
		dibujo_del_relleno.modulate = COLOR_ENOJADO
		_mostrar_reaccion(dibujo_enojado)
	elif avance <= PACIENCIA_APURADO:
		dibujo_del_relleno.modulate = COLOR_APURADO
		_mostrar_reaccion(dibujo_esperando)
	else:
		dibujo_del_relleno.modulate = COLOR_TRANQUILO
		_mostrar_reaccion(dibujo_esperando)


func esconder_paciencia() -> void:
	paciencia.visible = false


## Al cliente le entregaron lo que pidió, así que se va contento. Queda solo la carita
## feliz un momento, sin el pedido ni la barra, y después el globo se esconde solo.
func celebrar() -> void:
	if dibujo_feliz == null:
		return
	show()
	dibujo.hide()
	interrogacion.hide()
	paciencia.visible = false
	fondo.hide()
	_mostrar_reaccion(dibujo_feliz)
	await get_tree().create_timer(SEGUNDOS_DE_CELEBRACION).timeout
	fondo.show()
	hide()
