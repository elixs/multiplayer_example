extends Node

var is_passive_active: bool = false

# note: no se como va a implementarse lo del target xd
func execute(user: BaseCharacter, target: Vector3):
	print("executing base ability")
	# [Insert the ability here]
	pass

# note: if the passive effect can affect the teammate, the character class will
# need a reference to their teammate
func activatePassive(user: BaseCharacter):
	is_passive_active = true
	# [Insert the passive effect here]
	pass
	
func deactivatePassive(user: BaseCharacter):
	is_passive_active = false
	# [Undo the passive effect here]
	pass
