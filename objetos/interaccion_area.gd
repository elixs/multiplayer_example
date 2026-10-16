class_name InteraccionArea
extends Area3D

signal interact
signal interact_q
#signal players_nearby

@export var meshInstance: MeshInstance3D
@export var label: Label3D
@export var Objeto_Interactuable: ObjetoInteractuable
@export var duracion_animacion = 0


## Todas las áreas de interacción se juntan acá para poder preguntarse entre ellas
## cuál manda cuando el gato está tocando más de una.
const GRUPO: StringName = &"areas_de_interaccion"

var players: Array[Player]

# Dónde va el cartel respecto del objeto. Se guarda porque el cartel se saca de la
# jerarquía y se coloca a mano, así que ya no puede sacar su posición de su padre.
var _posicion_del_cartel: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	duracion_animacion = Objeto_Interactuable.tiempo_accion
	add_to_group(GRUPO)
	_preparar_cartel()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# El cartel se despega de la jerarquía del objeto y se orienta a mano hacia la cámara.
# Colgando del objeto heredaba su rotación y su escala, y por eso el texto se veía dado
# vuelta o espejado según desde dónde se mirara.
func _preparar_cartel() -> void:
	if label == null:
		return
	_posicion_del_cartel = label.position
	label.top_level = true
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	label.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("E_Interactuar"):
		if not monitoring: return # Si el puesto está apagado, ignoramos
		
		# Le preguntamos directo a las físicas de Godot quién está tocando el área
		for body in get_overlapping_bodies():
			var player = body as Player
			if player and player.get_multiplayer_authority() == multiplayer.get_unique_id():
				if not manda_sobre(player):
					return
				get_viewport().set_input_as_handled() # ¡CLAVE! Evita que el Player ejecute soltar_objeto()
				interact.emit()
				return

	if event.is_action_pressed("Q_Interactuar"):
		if not monitoring: return
		
		for body in get_overlapping_bodies():
			var player = body as Player
			if player and player.get_multiplayer_authority() == multiplayer.get_unique_id():
				if not manda_sobre(player):
					return
				get_viewport().set_input_as_handled()
				interact_q.emit()
				return


func _on_body_entered(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.push_back(player)
		
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			label.show()
			
		
func _on_body_exited(body: Node3D) -> void:
	var player: Player = body as Player
	if player:
		players.erase(player)
		if player.get_multiplayer_authority() == multiplayer.get_unique_id():
			label.hide()
			
# El cartel se coloca y se orienta cada cuadro, y va diciendo lo que el jugador puede
# hacer en este momento con el objeto.
func _process(_delta: float) -> void:
	if label == null:
		return
	var jugador: Player = jugador_local()
	label.visible = jugador != null and monitoring and manda_sobre(jugador)
	if not label.visible:
		return
	label.global_position = to_global(_posicion_del_cartel)
	label.text = Objeto_Interactuable.texto_de_ayuda(jugador)
	var camara: Camera3D = get_viewport().get_camera_3d()
	if camara == null:
		return
	# Se gira solo en el eje vertical para que el cartel quede de frente sin inclinarse.
	# look_at deja la espalda mirando a la cámara, así que después se da vuelta.
	var hacia: Vector3 = camara.global_position
	hacia.y = label.global_position.y
	if hacia.is_equal_approx(label.global_position):
		return
	label.look_at(hacia, Vector3.UP)
	label.rotate_object_local(Vector3.UP, PI)


## Si este mueble es el que manda para ese jugador en este momento. Nunca puede haber
## dos cosas interactuables a la vez: si el gato está apuntando a un ingrediente que
## puede levantar, gana el ingrediente, y si está tocando dos muebles gana el que tiene
## más cerca.
func manda_sobre(jugador: Player) -> bool:
	if jugador.objeto_en_mano == null and jugador.ingrediente_apuntado():
		return false
	var mi_distancia: float = jugador.global_position.distance_squared_to(global_position)
	for otra: Node in get_tree().get_nodes_in_group(GRUPO):
		var vecina: InteraccionArea = otra as InteraccionArea
		if vecina == null or vecina == self or not vecina.monitoring:
			continue
		if vecina.jugador_local() != jugador:
			continue
		if jugador.global_position.distance_squared_to(vecina.global_position) < mi_distancia:
			return false
	return true


## El jugador de esta máquina, si está dentro del área. Null si el que está al lado es
## el gato de otro jugador.
func jugador_local() -> Player:
	for jugador: Player in players:
		if is_instance_valid(jugador) and jugador.get_multiplayer_authority() == multiplayer.get_unique_id():
			return jugador
	return null
