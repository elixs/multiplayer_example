class_name BurbujaEmote
extends Node3D

# Burbuja que aparece sobre la cabeza del gato cuando lanza un emote. Se muestra en
# todas las máquinas, así que los demás jugadores la ven sobre el gato que la lanzó.
#
# El nodo cuelga de la raíz del gato, que tiene escala 0.155, así que el tamaño final en
# pantalla sale del pixel_size de los sprites. Se ajusta desde el inspector.

# Caja donde entra el ícono dentro del cuerpo de la burbuja, en píxeles de la textura.
const CAJA_ICONO: Vector2 = Vector2(300.0, 260.0)

# El cuerpo de la burbuja termina en y = 364 de una textura de 448 de alto, porque abajo
# va la colita. Por eso el ícono se corre un poco hacia arriba del centro de la imagen.
const ALTURA_ICONO: float = 42.0

const ESCALA_ENTRADA: float = 0.6
const DURACION_ENTRADA: float = 0.15
const DURACION_SALIDA: float = 0.35

## La cámara del gato va pegada a su cabeza, así que su propia burbuja le taparía
## media pantalla. Con esto activado el dueño no ve la suya y sí ve la de los demás.
## Si alguna vez la cámara se aleja, basta desactivarlo.
@export var ocultar_al_dueno: bool = true

@onready var fondo: Sprite3D = $Fondo
@onready var icono: Sprite3D = $Icono

var _tween: Tween


func _ready() -> void:
	hide()
	icono.position = Vector3(0.0, ALTURA_ICONO * fondo.pixel_size, 0.0)


# Muestra el ícono del emote durante unos segundos. Si ya había una burbuja encima, la
# nueva reemplaza a la anterior.
func mostrar(dibujo: Texture2D, segundos: float) -> void:
	if dibujo == null:
		return
	if ocultar_al_dueno and is_multiplayer_authority():
		return

	icono.texture = dibujo
	icono.pixel_size = fondo.pixel_size * _ajuste_de_icono(dibujo)

	if _tween and _tween.is_running():
		_tween.kill()

	show()
	scale = Vector3.ONE * ESCALA_ENTRADA
	fondo.modulate.a = 0.0
	icono.modulate.a = 0.0

	_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "scale", Vector3.ONE, DURACION_ENTRADA)
	_tween.parallel().tween_property(fondo, "modulate:a", 1.0, DURACION_ENTRADA)
	_tween.parallel().tween_property(icono, "modulate:a", 1.0, DURACION_ENTRADA)

	_tween.tween_interval(segundos)

	_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	_tween.tween_property(fondo, "modulate:a", 0.0, DURACION_SALIDA)
	_tween.parallel().tween_property(icono, "modulate:a", 0.0, DURACION_SALIDA)
	_tween.tween_callback(hide)


# Cuánto hay que achicar el ícono para que quepa en la burbuja sin deformarse. Los
# íconos del kit tienen tamaños distintos, así que cada uno necesita su propio ajuste.
func _ajuste_de_icono(dibujo: Texture2D) -> float:
	var tamano: Vector2 = dibujo.get_size()
	if tamano.x <= 0.0 or tamano.y <= 0.0:
		return 1.0
	return minf(CAJA_ICONO.x / tamano.x, CAJA_ICONO.y / tamano.y)
