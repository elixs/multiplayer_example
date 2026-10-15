class_name Player
extends CharacterBody3D

@export var speed: float = 1
@export var jump_speed: float = 3
@export var acceleration: float = 6
@export var mouse_sensitivy: float = 0.005
@export var camera_min_pitch: float = -20
@export var camera_max_pitch: float = 30
@export var spring_min_pitch: float = -50
@export var spring_max_pitch: float = 50

@export var is_emoteando: bool = false
# Los emotes que puede lanzar este gato. Los usan la rueda y los atajos K y L.
@export var emotes: EmoteSet
signal tiempo_trabajando(tiempo: int)

@onready var animation_player: AnimationPlayer = $GatoV5_Bone/AnimationPlayer
@onready var animation_tree: AnimationTree = $GatoV5_Bone/AnimationTree
@onready var action_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")
@onready var t_inicio: float = animation_player.get_animation("Esqueleto_acción_004").length

enum {C,R,L}
var curRot:int = C
@onready var intensidadR:float = 0
@onready var intensidadL:float = 0
@onready var fuerza_giro:float = 0

enum Posicion {LIBRE, ARRIBA_DE, ABAJO_D}
var posicion_actual : Posicion = Posicion.LIBRE
var gato_base: Player = null
var gato_jinete: Player = null
const  OFFSET_ALTURA: Vector3 = Vector3(0,0.5,0)
@onready var arriba_de: Area3D = $ArribaDe
@onready var capa: Node3D = $GatoV5_Bone/Esqueleto/Skeleton3D/Cube/Capa

enum {IDLE,WALK,RUN}
var curAnim: int = IDLE
@onready var walk_val: float = 0
@onready var run: float = 0
@export var blend_speed: int = 15

@onready var label_3d: Label3D = $GatoV5_Bone/Esqueleto/Skeleton3D/Cube/Label3D

@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var camera_3d: Camera3D = $SpringArm3D/Camera3D

@onready var burbuja_emote: BurbujaEmote = $BurbujaEmote

@onready var input_synchronizer: InputSynchronizer = $InputSynchronizer
@onready var sync_timer: Timer = $SyncTimer

@onready var model: Node3D = $GatoV5_Bone/Esqueleto
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# variables para tomar objetos
@onready var shape_cast: ShapeCast3D = $SpringArm3D/Camera3D/GrabArea
@onready var nodo_agarre: Marker3D = $SpringArm3D/Camera3D/GrabArea/GrabTarget
# tambien se usa camera_3d

var objeto_en_mano: Ingrediente = null

func _ready() -> void:
	sync_timer.timeout.connect(_on_sync_timeout)
	
	arriba_de.body_entered.connect(_on_arriba_de_body_entered)
	
	var player_data: Statics.PlayerData = Game.instance.get_player(get_multiplayer_authority())
	label_3d.text = player_data.name
	capa.visible = false
	label_3d.visible = not is_multiplayer_authority()
	#sprite_puntero.visible = is_multiplayer_authority()
	camera_3d.current = is_multiplayer_authority()
	if is_multiplayer_authority():
		#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		sync_timer.start()

func _on_arriba_de_body_entered(body: Node3D) -> void:
	if body is Player and body != self:
		if self.posicion_actual == Posicion.LIBRE:
			if body.is_multiplayer_authority() and body.posicion_actual == Posicion.LIBRE:
				body.intentar_subir(self)

func _input(event: InputEvent) -> void:
	#Mouse
	if event.is_action_pressed("Menu"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return
	#K y L botones
	if event.is_action_pressed("Idle1") and not is_emoteando:
		lanzar_emote(&"hola")
	if event.is_action_pressed("Idle2") and not is_emoteando:
		lanzar_emote(&"no")
	
	# tomar objetos
	if event.is_action_pressed("E_Interactuar"):
		if objeto_en_mano:
			soltar_objeto()
		else:
			tomar_objeto()

	var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
	if mouse_motion:
		spring_arm_3d.rotation.y = spring_arm_3d.rotation.y - input_synchronizer.mouse_vector.x * mouse_sensitivy
		camera_3d.rotation.x = clamp(
			camera_3d.rotation.x - input_synchronizer.mouse_vector.y * mouse_sensitivy,
			deg_to_rad(camera_min_pitch),
			deg_to_rad(camera_max_pitch)
		)

func _process(_delta: float) -> void:
	pass
	
func handle_animation(delta: float) -> void:
	match curAnim:
		IDLE:
			walk_val = lerpf(walk_val,0,blend_speed*delta)
			run = lerpf(run,0,blend_speed*delta)
		WALK:
			walk_val = lerpf(walk_val,1.5,blend_speed*delta)
			run = lerpf(run,0,blend_speed*delta)
		RUN:
			walk_val = lerpf(walk_val,0,blend_speed*delta)
			run = lerpf(run,1.5,blend_speed*delta)

	match curRot:
		R:
			intensidadL = lerpf(intensidadL,0,blend_speed*delta/3)
			intensidadR = lerpf(intensidadR,fuerza_giro,blend_speed*delta/3)
		L:
			intensidadL = lerpf(intensidadL,fuerza_giro,blend_speed*delta/3)
			intensidadR = lerpf(intensidadR,0,blend_speed*delta/3)
		C:
			intensidadL = lerpf(intensidadL,0,blend_speed*delta/3)
			intensidadR = lerpf(intensidadR,0,blend_speed*delta/3)
	update_tree()

func update_tree() -> void:
	animation_tree["parameters/Walk/blend_amount"] = walk_val
	animation_tree["parameters/Run/blend_amount"] = run
	animation_tree["parameters/RotandoR/add_amount"] = intensidadR
	animation_tree["parameters/RotandoL/add_amount"] = intensidadL
		
func _physics_process(delta: float) -> void:
	match posicion_actual:
		Posicion.LIBRE:
			comportamiento_normal(delta)	
		Posicion.ARRIBA_DE:
			comportamiento_arriba(delta)	
		Posicion.ABAJO_D:
			comportamiento_abajo(delta)	
	
func comportamiento_normal(delta: float) -> void:
	speed = lerpf(speed,input_synchronizer.move_speed,0.05)
	if is_emoteando:
		velocity.x = move_toward(velocity.x,0,acceleration)
		velocity.z = move_toward(velocity.z,0,acceleration)
		move_and_slide()
		return
		
	if not is_on_floor():
		velocity += get_gravity()*delta
	animation_player.speed_scale = max(int(speed * 1), 1)
	
	if not objeto_en_mano and shape_cast.is_colliding():
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if collider is Ingrediente and collider.is_in_group("tomable") and collider.held_by == 0:
				collider.is_hovered = true
				break
				
	if objeto_en_mano:
		var target_pos = nodo_agarre.global_position
		var target_rot = nodo_agarre.global_rotation
		
		objeto_en_mano.rpc_id(1, "update_held_position", target_pos, target_rot)
	
	if not is_emoteando:
		
		#Controlador de la animacion de giro del gato
		var dif_angulo: float = angle_difference(model.rotation.y, spring_arm_3d.rotation.y)
		var umbral_giro: float = 0.005
		fuerza_giro = lerpf(fuerza_giro,clampf(absf(dif_angulo) / (PI/4), 0, 1.5),0.2)
		if dif_angulo > umbral_giro:
			curRot = R
		elif dif_angulo < -umbral_giro:
			curRot = L
		else:
			curRot = C
		
		#El giro del gato
		model.rotation.y = lerp_angle(
			model.rotation.y,
			spring_arm_3d.rotation.y,
			10 * delta
		)
		collision_shape_3d.rotation = model.rotation
	

	if not input_synchronizer.move_input.is_zero_approx() and is_on_floor():
		if speed < 2.4:
			curAnim = WALK
		else:
			curAnim = RUN
	else:
		curAnim = IDLE

	if input_synchronizer.jump:
		if is_on_floor():
			curAnim = IDLE
			velocity.y = jump_speed
		input_synchronizer.jump = false
		
	handle_animation(delta)
	
	var move_input: Vector2 = input_synchronizer.move_input
	var direction: Vector3 = model.transform.basis * Vector3(move_input.x, 0, move_input.y)
	var target: Vector2 = Vector2(direction.x, direction.z) * speed
	var current: Vector2 = Vector2(velocity.x, velocity.z)
	var result: Vector2 = current.move_toward(target, acceleration * delta)
	velocity.x = result.x
	velocity.z = result.y
	
	move_and_slide()

func comportamiento_arriba(delta: float) -> void:
	if is_instance_valid(gato_base):

		global_position = gato_base.global_position + OFFSET_ALTURA
		velocity = Vector3.ZERO

		model.rotation.y = lerp_angle(
			model.rotation.y,
			spring_arm_3d.rotation.y,
			10 * delta
		)
		collision_shape_3d.rotation = model.rotation
			
		curAnim = IDLE
		handle_animation(delta)
	if input_synchronizer.jump:
		desmontarse()
	
func comportamiento_abajo(delta: float) -> void:
	speed = lerpf(speed,input_synchronizer.move_speed,0.05)
	
	model.rotation.y = lerp_angle(
			model.rotation.y,
			spring_arm_3d.rotation.y,
			10 * delta
		)
	collision_shape_3d.rotation = model.rotation
	
	if not input_synchronizer.move_input.is_zero_approx() and is_on_floor():
		if speed < 2.4:
			curAnim = WALK
		else:
			curAnim = RUN
	else:
		curAnim = IDLE
	handle_animation(delta)
	
	var move_input: Vector2 = input_synchronizer.move_input
	var direction: Vector3 = model.transform.basis * Vector3(move_input.x, 0, move_input.y)
	var target: Vector2 = Vector2(direction.x, direction.z) * speed
	var current: Vector2 = Vector2(velocity.x, velocity.z)
	var result: Vector2 = current.move_toward(target, acceleration * delta)
	velocity.x = result.x
	velocity.z = result.y

	move_and_slide()

func intentar_subir(otro_gato: Player) -> void:
	if not is_multiplayer_authority():
		return
	if self.posicion_actual == Posicion.LIBRE and otro_gato.posicion_actual == Posicion.LIBRE:
		rpc("rpc_sincronizar_apilamiento", otro_gato.get_path())
		

@rpc("any_peer", "call_local", "reliable")
func rpc_sincronizar_apilamiento(ruta_gato_base: NodePath) -> void:
	var base:Player= get_node_or_null(ruta_gato_base)
	if not base:
		return
		
	self.posicion_actual = Posicion.ARRIBA_DE
	self.gato_base = base
	self.capa.visible = true
	
	base.posicion_actual = Posicion.ABAJO_D
	base.gato_jinete = self
	base.visible = false
	
	#collision_shape_3d.set_deferred("disabled", true)
	arriba_de.set_deferred("monitoring", false)
			
func desmontarse() -> void:
	if not is_multiplayer_authority():
		return
		
	if posicion_actual == Posicion.ARRIBA_DE and is_instance_valid(gato_base):
		rpc("rpc_sincronizar_desmonte")

@rpc("any_peer", "call_local", "reliable")
func rpc_sincronizar_desmonte() -> void:
	if is_instance_valid(gato_base):
		gato_base.posicion_actual = Posicion.LIBRE
		gato_base.gato_jinete = null
		gato_base.visible = true
		
	self.posicion_actual = Posicion.LIBRE
	self.gato_base = null
	self.capa.visible = false
	
	
	#collision_shape_3d.set_deferred("disabled", false)
	arriba_de.set_deferred("monitoring", true)

	if is_multiplayer_authority():
		velocity.y = jump_speed
		velocity.z = -4.0

func _ajustar_camara(largo: float, alto:float) -> void:
	spring_arm_3d.spring_length += largo
	spring_arm_3d.position.y += alto
	
# Punto de entrada único para lanzar un emote. Lo usan la rueda y los atajos K y L.
func lanzar_emote(id: StringName) -> void:
	if not is_multiplayer_authority():
		return
	mostrar_emote.rpc(id)

# Muestra el emote en todas las máquinas: la burbuja sobre la cabeza siempre, y la
# animación del gato solo si el emote trae una.
@rpc("any_peer","call_local","reliable")
func mostrar_emote(id: StringName) -> void:
	# Solo el dueño del gato decide qué emote lanza. En la llamada local el emisor es
	# 0, porque no vino de la red.
	var emisor: int = multiplayer.get_remote_sender_id()
	if emisor != 0 and emisor != get_multiplayer_authority():
		return
	if emotes == null:
		return
	var emote: EmoteDef = emotes.buscar_por_id(id)
	if emote == null:
		return
	burbuja_emote.mostrar(emote.icono, emote.duracion_burbuja)
	if emote.tiene_animacion():
		_reproducir_emote_animado(emote.animacion_oneshot, emote.animacion_duracion)

@rpc("any_peer","call_local","reliable")
func trigger_emotiza1() -> void:
	emotiza1()
	
func emotiza1() -> void:
	_reproducir_emote_animado(&"Idle1", 4.5)

@rpc("any_peer","call_local","reliable")
func trigger_emotiza2() -> void:
	emotiza2()
	
func emotiza2() -> void:
	_reproducir_emote_animado(&"Idle2", 3.5)

# Dispara el OneShot del AnimationTree que corresponde al emote. Mientras dura, el
# gato queda quieto y la cámara se aleja un poco para que se vea entero.
func _reproducir_emote_animado(nodo_oneshot: StringName, duracion: float) -> void:
	if is_emoteando:
		return
	is_emoteando = true
	_ajustar_camara(4,-1)
	animation_tree.set("parameters/%s/request" % nodo_oneshot, AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	await get_tree().create_timer(duracion).timeout
	_ajustar_camara(-4,1)
	is_emoteando = false

#Accion predeterminada
@rpc("any_peer","call_local","reliable")
func trigger_emotiza(duracion:float) -> void:
	if is_emoteando:
		return
	_ejecutar_animacion_emotiza(duracion)
	
func _ejecutar_animacion_emotiza(duracion: float) -> void:
	is_emoteando = true
	tiempo_trabajando.emit(duracion)
	_ajustar_camara(3,1)
	var t_desarrollo: float = max(0.0, duracion - t_inicio *2)
	action_state_machine.travel("Inicio")

	var tween_in: Tween = create_tween()
	tween_in.tween_property(animation_tree, "parameters/Accion/blend_amount", 1.0, 0.15)
	
	await get_tree().create_timer(t_inicio + t_desarrollo).timeout
	action_state_machine.travel("Fin")
	await get_tree().create_timer(t_inicio-0.2).timeout
	_ajustar_camara(-3,-1)
	var tween_out: Tween = create_tween()
	tween_out.tween_property(animation_tree, "parameters/Accion/blend_amount", 0.0, 0.2)
	await tween_out.finished
	is_emoteando = false
	

func _on_sync_timeout() -> void:
	_sync.rpc(global_position, velocity)
	_sync2.rpc(spring_arm_3d.rotation)

@rpc("call_local", "unreliable")
func _sync(pos: Vector3, vel: Vector3) -> void:
	global_position = global_position.lerp(pos, 0.5)
	velocity = velocity.lerp(vel, 0.5)

@rpc("call_local","unreliable")
func _sync2(rot:Vector3) -> void:
	spring_arm_3d.rotation = spring_arm_3d.rotation.lerp(rot, 1)
	
# funciones auxiliares tomar objetos
func tomar_objeto() -> void:
	if shape_cast.is_colliding():
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if collider is RigidBody3D and collider.is_in_group("tomable") and collider.held_by == 0:
				collider.rpc_id(1, "request_tomar", multiplayer.get_unique_id())
				break

func soltar_objeto() -> void:
	print("soltando objeto")
	if objeto_en_mano:
		print("objeto en mano se puede soltar")
		var throw_velocity = -global_transform.basis.z * 5.0
		var obj = objeto_en_mano
		objeto_en_mano = null
		if objeto_en_mano:
			print("objeto no se solto en player")
		
		obj.rpc_id(1, "request_soltar", multiplayer.get_unique_id(), throw_velocity)

func ceder_objeto(pos: Vector3) -> void:
	
	if objeto_en_mano:
		var obj = objeto_en_mano
		objeto_en_mano = null
		obj.soltar_en(pos)
