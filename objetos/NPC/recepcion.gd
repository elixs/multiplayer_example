class_name ControladorRecepcion
extends Node3D

@export var puestos_clientes: Array[PuestoCliente]
@export var tiempo_llegada_min: float = 3.0
@export var tiempo_llegada_max: float = 8.0

var timer: Timer

func _ready() -> void:
	if multiplayer.is_server():
		timer = Timer.new()
		timer.one_shot = true
		timer.timeout.connect(_spawnear_cliente)
		add_child(timer)
		_iniciar_proximo_cliente()

func _iniciar_proximo_cliente() -> void:
	var tiempo_aleatorio = randf_range(tiempo_llegada_min, tiempo_llegada_max)
	timer.start(tiempo_aleatorio)

func _spawnear_cliente() -> void:
	var puestos_libres = puestos_clientes.filter(func(p): return not p.ocupado)
	
	if puestos_libres.size() > 0:

		var puesto_elegido: PuestoCliente = puestos_libres.pick_random()
		puesto_elegido._set_ocupado_rpc.rpc(true)
		print("Servidor: NPC apareció en ", puesto_elegido.name)
	
	_iniciar_proximo_cliente()
