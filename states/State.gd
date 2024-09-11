extends Node
class_name State

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = 1000
var jumps = 0
var stunned: bool = false
var parent: CharacterBody2D
signal state_transition

func enter() -> void:
	pass

func exit() -> void:
	pass

func update(event: InputEvent) -> State:
	return self
	
func autoUpdate() -> State:
	return null
	
func Physics_update(delta:float) -> void:
	pass
