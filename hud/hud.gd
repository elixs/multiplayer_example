extends Control

@onready var hud: Control = $"."


@onready var mostradorDinero: Label = %Dinero
@onready var tiempo: Label = %Tiempo
@onready var aguja: TextureRect = %Aguja
@export var jugador: Player
@onready var barra_trabajo: TextureProgressBar = %BarraTrabajo

# Grados que recorre la aguja del reloj a lo largo de una jornada: parte en el
# amanecer, pasa por el sol y termina en el anochecer. Salen de reloj_medidas.json.
const RELOJ_AMANECER: float = -118.3
const RELOJ_ANOCHECER: float = 65.8

# El reloj del GameManager ya viene corriendo cuando aparece el HUD, así que la
# duración de la jornada se toma del primer valor que llega.
var _tiempo_total: int = 0


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
	
func _conectar_game_manager() -> void:
	var gm:GameManager = GameManager.instance
	gm.timer_updated.connect(_on_tiempo_actualizado)
	gm.money_updated.connect(_on_dinero_actualizado)
	jugador.tiempo_trabajando.connect(_trabajando)
	_on_tiempo_actualizado(gm.game_time)
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

func _on_tiempo_actualizado(_nuevo_tiempo:int) -> void:
	var minutos : int = int(float(_nuevo_tiempo) / 60)
	var segundos : int = _nuevo_tiempo % 60
	tiempo.text = "%02d:%02d" % [minutos, segundos]
	_mover_aguja(_nuevo_tiempo)
	
func _mover_aguja(restante: int) -> void:
	if _tiempo_total <= 0:
		_tiempo_total = maxi(restante, 1)
	var avance: float = clampf(1.0 - float(restante) / float(_tiempo_total), 0.0, 1.0)
	aguja.rotation_degrees = lerpf(RELOJ_AMANECER, RELOJ_ANOCHECER, avance)
	
func _on_dinero_actualizado(nuevo_dinero:int) -> void:
	mostradorDinero.text = "%d" % nuevo_dinero
