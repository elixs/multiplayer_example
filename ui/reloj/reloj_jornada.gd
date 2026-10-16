class_name RelojJornada
extends Control

# Reloj de la jornada. La esfera tiene el día arriba y la noche abajo, y la aguja recorre
# el arco del amanecer al anochecer a medida que baja el tiempo del GameManager.
#
# El mismo componente se usa en el HUD y dentro de la tienda, por eso las piezas van
# ancladas en proporciones y el tamaño de los dígitos se ajusta desde el inspector.

# Grados que recorre la aguja a lo largo de una jornada. Salen de reloj_medidas.json.
const RELOJ_AMANECER: float = -118.3
const RELOJ_ANOCHECER: float = 65.8

# La aguja gira sobre su punta de abajo, que en el dibujo está casi en el borde inferior.
const PIVOTE_AGUJA: Vector2 = Vector2(0.5, 0.958)

## Los dígitos con el tiempo que queda. Apagarlos deja solo la esfera y la aguja.
@export var mostrar_digitos: bool = true

## Tamaño de los dígitos. Se ajusta a mano porque el reloj se usa a dos tamaños.
@export var tamano_digitos: int = 26

@onready var aguja: TextureRect = %Aguja
@onready var placa: TextureRect = %Placa
@onready var digitos: Label = %Digitos

# La jornada ya viene corriendo cuando aparece el reloj, así que su duración total se
# toma del primer valor útil que llega. Mientras no haya uno, la aguja se queda en el
# amanecer en vez de quedar trabada en una duración falsa.
var _tiempo_total: int = 0


func _ready() -> void:
	placa.visible = mostrar_digitos
	digitos.visible = mostrar_digitos
	digitos.add_theme_font_size_override("font_size", tamano_digitos)
	aguja.resized.connect(_acomodar_pivote)
	_acomodar_pivote()
	if GameManager.instance:
		_conectar_game_manager()
	else:
		await get_tree().process_frame
		if GameManager.instance:
			_conectar_game_manager()


func _conectar_game_manager() -> void:
	var gestor: GameManager = GameManager.instance
	gestor.timer_updated.connect(mostrar_tiempo)
	mostrar_tiempo(gestor.game_time)


# Deja el reloj en un tiempo dado. Es público para que una escena de prueba lo pueda
# mover sin necesitar una partida en red.
func mostrar_tiempo(segundos_restantes: int) -> void:
	if _tiempo_total <= 0:
		_tiempo_total = maxi(segundos_restantes, 0)
	var minutos: int = int(float(segundos_restantes) / 60.0)
	var segundos: int = segundos_restantes % 60
	digitos.text = "%02d:%02d" % [minutos, segundos]
	var avance: float = 0.0
	if _tiempo_total > 0:
		avance = clampf(1.0 - float(segundos_restantes) / float(_tiempo_total), 0.0, 1.0)
	aguja.rotation_degrees = lerpf(RELOJ_AMANECER, RELOJ_ANOCHECER, avance)


func _acomodar_pivote() -> void:
	aguja.pivot_offset = aguja.size * PIVOTE_AGUJA
