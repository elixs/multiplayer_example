extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var potato_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var reach: CollisionShape2D = $Reach/CollisionShape2D
@onready var caught: Hurtbox = $Caught
@onready var state_machine = $StateMachine
@export var potato_scene: PackedScene
@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer


var JUMP_VELOCITY = 400.0
var ACCELERATION = 1000
var jumps = 0
var potatos = 0
var has_potato = false
var player
var pos

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000

func setup(player_data: Statics.PlayerData,pos_:int,main: Node2D) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	pos= pos_

func _ready():
	reach.disabled = true
	state_machine.init(self)
	
func _input(event:InputEvent) -> void:
	if is_multiplayer_authority():
		state_machine.handle_inputs(event)
		if has_potato && not state_machine.is_frozen:
			if event.is_action_pressed("lanzar"):
				throw_Potato()
			if event.is_action_pressed("pintar"):
				reach.disabled = false	
		if event.is_action_released("pintar"):
			reach.disabled = true	

func _process(delta) -> void:
	if is_multiplayer_authority():
		state_machine.handle_animations()	
		#has_potato = Main.papas[pos]
		#Debug.log(Main.papas[pos])
					

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		state_machine.handle_physics(delta) 
		move_and_slide()
		send_position.rpc(position,velocity)
		
			
@rpc("reliable")		
func send_animation(animation: StringName)	-> void:
	animations.play(animation)
	
@rpc("reliable")
func stop_animation() -> void:
	animations.stop()

@rpc()
func send_sprite(scale: float) -> void:
	sprite.scale.x = scale
	
@rpc()
func send_position(pos:Vector2, vel: Vector2) -> void:
	position = lerp(position,pos,0.5)
	velocity = lerp(velocity,vel,0.5)
	
	
@rpc()
func throw_Potato() -> void:
	if not potato_scene:
		Debug.log("Cant throw potato")
		return
	var potato_inst = potato_scene.instantiate()
	potato_inst.add_to_group("potato")
	potato_inst.global_position = global_position	
	potato_inst.global_rotation = global_rotation
	potato_spawner.add_child(potato_inst, true)
	potato_inst.setup.rpc(get_tree().get_multiplayer().get_unique_id())

@rpc()
func update_sprite(frame: int) -> void:
	sprite.frame = frame
	
func potato_changed(id_: int) -> void:
	Debug.log("xd")
	set_potato_state(false)
	rpc_id(get_multiplayer_authority(),"set_potato_state",true)
	#rpc_id(id_,"set_potato_state",false)

@rpc("any_peer","call_local","reliable")
func notify_passed_potato()->void:
	Main.rpc("swap_potato",pos)
	has_potato = Main.papas[pos]	
		
@rpc("any_peer","reliable")		
func set_potato_state(state:bool) -> void:
	has_potato = state
	#has_potato = Main.papas[pos]
	
func stun() -> void:
	rpc_id(get_multiplayer_authority(),"notify_stun")

@rpc("any_peer","call_local","reliable")	
func notify_stun() -> void:
	state_machine.is_frozen = true
	state_machine.change_state(state_machine.current_state,state_machine.states["stunned"])
	timer.start()
	
