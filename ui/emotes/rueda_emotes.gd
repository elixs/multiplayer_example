class_name RuedaEmotes
extends Control

# Rueda radial para comunicarse con los otros gatos. Se mantiene apretada la acción
# "emote_wheel", se apunta con el mouse o con el stick derecho y al soltar se lanza el
# emote del segmento resaltado. Soltar cerca del centro no lanza nada.
#
# La rueda solo existe de verdad para el jugador dueño de este gato. En las copias de
# los demás queda apagada, igual que el HUD.

# Medidas del lienzo original de los sprites, en píxeles de arte. Salen del archivo
# assets/ui/rueda_emotes/rueda_medidas.json y las comparten las ruedas de 4, 6 y 8.
const CENTRO: Vector2 = Vector2(610.0, 610.0)
const RADIO_ICONOS: float = 425.0
const CAJA_ICONO: Vector2 = Vector2(240.0, 240.0)

# El puntero es una patita con un cono que apunta hacia abajo. Se la hace girar en torno
# al centro para que el cono caiga sobre el segmento elegido.
const ORBITA_PUNTERO: float = 790.0
const CENTRO_PATA_PUNTERO: Vector2 = Vector2(96.0, 90.0)

# El lienzo de 1220 se achica a 0.4 para que la rueda entre cómoda en 1280x720. Es un
# múltiplo exacto del píxel de arte, así que los escalones del contorno quedan parejos.
const ESCALA_RUEDA: float = 0.4

# Radio máximo del cursor virtual, en píxeles de pantalla. El cursor parte en el centro
# al abrir la rueda y acumula el movimiento del mouse, así funciona igual con el cursor
# capturado o libre.
const RADIO_CURSOR: float = 150.0
const ZONA_MUERTA: float = 25.0
const ZONA_MUERTA_STICK: float = 0.3

const ESCALA_ICONO_APUNTADO: float = 1.1
const DURACION_APERTURA: float = 0.12
const DURACION_CIERRE: float = 0.08

# Mientras no se puede lanzar nada la rueda se ve apagada, para que se note que el gato
# está ocupado y no que la rueda dejó de responder.
const COLOR_BLOQUEADA: Color = Color(0.62, 0.58, 0.54)

# Enfriamiento de los emotes que solo muestran burbuja, para que no se manden en ráfaga.
# Los que tienen animación ya quedan bloqueados por is_emoteando del gato.
const ESPERA_ENTRE_EMOTES: float = 1.0

const CARPETA_RUEDAS: String = "res://assets/ui/rueda_emotes"

@export var jugador: Player
## Texto del medallón cuando no hay ningún segmento apuntado.
@export var texto_sin_seleccion: String = "Emotes"

# La lista de emotes sale del gato, para que la rueda y los atajos de teclado usen
# siempre la misma y no haya dos listas que se puedan desincronizar.
var emotes: EmoteSet

@onready var rueda: Control = %Rueda
@onready var base: TextureRect = %Base
@onready var resaltado: TextureRect = %Resaltado
@onready var contenedor_iconos: Control = %Iconos
@onready var etiqueta: Label = %Etiqueta
@onready var puntero_pivote: Control = %PunteroPivote
@onready var puntero: TextureRect = %Puntero

var abierta: bool = false

var _segmentos: int = 0
var _indice_apuntado: int = -1
var _cursor: Vector2 = Vector2.ZERO
var _resaltados: Array[Texture2D] = []
var _iconos: Array[TextureRect] = []
var _tween: Tween
var _proximo_emote_msec: int = 0


func _ready() -> void:
	hide()
	modulate.a = 0.0
	rueda.pivot_offset = CENTRO
	rueda.scale = Vector2.ONE * ESCALA_RUEDA
	set_process(false)
	# Solo el dueño del gato maneja su rueda. Las copias de los otros no escuchan nada.
	set_process_input(is_multiplayer_authority())
	if is_multiplayer_authority():
		if jugador:
			emotes = jugador.emotes
		_armar_rueda()


func _input(event: InputEvent) -> void:
	if not abierta:
		if event.is_action_pressed("emote_wheel"):
			_abrir()
			get_viewport().set_input_as_handled()
		return

	if event.is_action_released("emote_wheel"):
		_cerrar(true)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("Menu") or _es_clic_derecho(event):
		_cerrar(false)
		get_viewport().set_input_as_handled()
		return

	var movimiento: InputEventMouseMotion = event as InputEventMouseMotion
	if movimiento:
		# La rueda se queda con el movimiento del mouse para que la cámara, que escucha
		# en _unhandled_input, no gire mientras el jugador apunta.
		_mover_cursor(movimiento.relative)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var stick: Vector2 = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	if stick.length() >= ZONA_MUERTA_STICK:
		# Con mando el stick apunta directo: el cursor salta a donde está inclinado.
		_cursor = stick.limit_length(1.0) * RADIO_CURSOR
		_refrescar_seleccion()
	rueda.modulate = Color.WHITE if _puede_lanzar() else COLOR_BLOQUEADA


# Carga los sprites de la rueda que corresponde a la cantidad de emotes y reparte un
# ícono por segmento.
func _armar_rueda() -> void:
	if emotes == null or emotes.emotes.is_empty():
		push_warning("RuedaEmotes: falta asignar el EmoteSet, la rueda queda apagada")
		set_process_input(false)
		return

	_segmentos = emotes.cantidad_segmentos()
	base.texture = _cargar_textura("%s/rueda_%d/rueda_%d_base.png" % [CARPETA_RUEDAS, _segmentos, _segmentos])
	_resaltados.clear()
	for indice: int in _segmentos:
		_resaltados.append(_cargar_textura("%s/rueda_%d/resaltado_%d_%d.png" % [CARPETA_RUEDAS, _segmentos, _segmentos, indice]))

	_crear_iconos()
	puntero.position = Vector2(0.0, -ORBITA_PUNTERO) - CENTRO_PATA_PUNTERO
	_pintar_seleccion()


func _crear_iconos() -> void:
	for hijo: Node in contenedor_iconos.get_children():
		contenedor_iconos.remove_child(hijo)
		hijo.queue_free()
	_iconos.clear()

	for indice: int in _segmentos:
		var cuadro: TextureRect = TextureRect.new()
		# Los íconos del kit tienen tamaños distintos, así que cada uno va dentro de un
		# cuadro fijo y se ajusta sin deformarse.
		cuadro.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cuadro.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		cuadro.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cuadro.size = CAJA_ICONO
		cuadro.pivot_offset = CAJA_ICONO * 0.5
		cuadro.position = _centro_de_segmento(indice) - CAJA_ICONO * 0.5
		var emote: EmoteDef = emotes.obtener(indice)
		if emote:
			cuadro.texture = emote.icono
		contenedor_iconos.add_child(cuadro)
		_iconos.append(cuadro)


# Centro del ícono de un segmento dentro del lienzo de 1220. El segmento 0 va arriba y
# los demás siguen en sentido horario, tal como vienen dibujados los sprites.
func _centro_de_segmento(indice: int) -> Vector2:
	var angulo: float = deg_to_rad(_angulo_de_segmento(indice))
	return CENTRO + Vector2(sin(angulo), -cos(angulo)) * RADIO_ICONOS


func _angulo_de_segmento(indice: int) -> float:
	return 360.0 / float(_segmentos) * float(indice)


func _abrir() -> void:
	if _segmentos == 0:
		return
	abierta = true
	_cursor = Vector2.ZERO
	_refrescar_seleccion()
	rueda.modulate = Color.WHITE if _puede_lanzar() else COLOR_BLOQUEADA
	show()
	set_process(true)

	_matar_tween()
	modulate.a = 0.0
	rueda.scale = Vector2.ONE * ESCALA_RUEDA * 0.85
	_tween = create_tween().set_parallel().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, DURACION_APERTURA)
	_tween.tween_property(rueda, "scale", Vector2.ONE * ESCALA_RUEDA, DURACION_APERTURA)


func _cerrar(lanzar: bool) -> void:
	abierta = false
	set_process(false)
	var elegido: EmoteDef = emotes.obtener(_indice_apuntado) if lanzar else null
	_indice_apuntado = -1
	_pintar_seleccion()

	_matar_tween()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, DURACION_CIERRE)
	_tween.tween_callback(hide)

	if elegido and _puede_lanzar():
		_proximo_emote_msec = Time.get_ticks_msec() + int(ESPERA_ENTRE_EMOTES * 1000.0)
		jugador.lanzar_emote(elegido.id)


func _mover_cursor(relativo: Vector2) -> void:
	_cursor = (_cursor + relativo).limit_length(RADIO_CURSOR)
	_refrescar_seleccion()


func _refrescar_seleccion() -> void:
	var nuevo: int = _calcular_indice_apuntado()
	if nuevo == _indice_apuntado:
		return
	_indice_apuntado = nuevo
	_pintar_seleccion()


# Convierte el cursor virtual en el número de segmento al que apunta. El 0 está arriba,
# así que primero se corre medio segmento para que su zona quede centrada en el tope.
func _calcular_indice_apuntado() -> int:
	if _segmentos == 0 or _cursor.length() < ZONA_MUERTA:
		return -1
	var paso: float = 360.0 / float(_segmentos)
	var grados: float = fposmod(rad_to_deg(atan2(_cursor.x, -_cursor.y)), 360.0)
	return int(fposmod(grados + paso * 0.5, 360.0) / paso) % _segmentos


func _pintar_seleccion() -> void:
	var emote: EmoteDef = emotes.obtener(_indice_apuntado) if emotes else null
	var hay_seleccion: bool = emote != null

	resaltado.visible = hay_seleccion
	puntero_pivote.visible = hay_seleccion
	if hay_seleccion:
		resaltado.texture = _resaltados[_indice_apuntado]
		puntero_pivote.rotation_degrees = _angulo_de_segmento(_indice_apuntado)

	etiqueta.text = emote.nombre if hay_seleccion else texto_sin_seleccion
	for indice: int in _iconos.size():
		var crece: bool = hay_seleccion and indice == _indice_apuntado
		_iconos[indice].scale = Vector2.ONE * (ESCALA_ICONO_APUNTADO if crece else 1.0)


# Hay emote disponible cuando el gato no está en medio de otra animación y ya pasó el
# enfriamiento del emote anterior.
func _puede_lanzar() -> bool:
	if jugador == null or jugador.is_emoteando:
		return false
	return Time.get_ticks_msec() >= _proximo_emote_msec


func _es_clic_derecho(event: InputEvent) -> bool:
	var boton: InputEventMouseButton = event as InputEventMouseButton
	return boton != null and boton.pressed and boton.button_index == MOUSE_BUTTON_RIGHT


func _cargar_textura(ruta: String) -> Texture2D:
	var textura: Texture2D = load(ruta) as Texture2D
	if textura == null:
		push_warning("RuedaEmotes: no se encontró la textura %s" % ruta)
	return textura


func _matar_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
