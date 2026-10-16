extends Control

@onready var hud: Control = $"."


@onready var mostradorDinero: Label = %Dinero
@export var jugador: Player
## El panel de la tienda que abre el botón del toldo. Vive fuera del HUD porque tapa
## la pantalla entera, así que se enlaza desde la escena del gato.
@export var tienda: Tienda
@onready var barra_trabajo: TextureProgressBar = %BarraTrabajo
@onready var boton_tienda: Button = %BotonTienda

func _ready() -> void:
	if GameManager.instance:
		_conectar_game_manager()
	else:
		await  get_tree().process_frame
		if GameManager.instance:
			_conectar_game_manager()
	if not is_multiplayer_authority():
		hud.hide()
		barra_trabajo.visible = false
	_preparar_tienda()
	
# El botón solo aparece si la escena trae una tienda enlazada. Mientras está abierta el
# gato deja de caminar, porque el jugador está mirando el panel y no la cocina.
func _preparar_tienda() -> void:
	boton_tienda.visible = tienda != null
	if tienda == null:
		return
	boton_tienda.pressed.connect(_abrir_tienda)
	tienda.cerrada.connect(_al_cerrar_tienda)

# El HUD se esconde entero mientras dura la tienda. El panel lo tapaba a medias y el
# reloj quedaba cortado por el borde, y además la tienda ya muestra el dinero.
func _abrir_tienda() -> void:
	tienda.abrir()
	_cambiar_marca_de_interfaz(true)
	hud.hide()

func _al_cerrar_tienda() -> void:
	_cambiar_marca_de_interfaz(false)
	hud.visible = is_multiplayer_authority()

func _cambiar_marca_de_interfaz(abierta: bool) -> void:
	if jugador and jugador.input_synchronizer:
		jugador.input_synchronizer.interfaz_abierta = abierta

func _conectar_game_manager() -> void:
	var gm:GameManager = GameManager.instance
	gm.money_updated.connect(_on_dinero_actualizado)
	# La barra de trabajo depende del gato. Sin gato asignado el resto del HUD igual sirve.
	if jugador:
		jugador.tiempo_trabajando.connect(_trabajando)
	_on_dinero_actualizado(gm.dinero_recaudado)

func _trabajando(tiempo:int) -> void:
	barra_trabajo.visible = true
	barra_trabajo.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(barra_trabajo, "modulate:a", 1.0, 0.3)
	tween.tween_property(barra_trabajo, "value", 100, tiempo-0.4)
	await tween.finished
	
	var fade_tween: Tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN)
	
	fade_tween.tween_property(barra_trabajo, "modulate:a", 0.0, 0.4)
	await fade_tween.finished
	barra_trabajo.visible = false
	barra_trabajo.value = 0

func _on_dinero_actualizado(nuevo_dinero:int) -> void:
	mostradorDinero.text = "%d" % nuevo_dinero
