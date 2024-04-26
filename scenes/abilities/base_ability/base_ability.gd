extends Node


# note: no se como va a implementarse lo del target xd
func execute(user: BaseCharacter, target: Vector3):
	pass

# note: if the passive effect can affect the teammate, the character will
# need a reference to their teammate
func activatePassiveEffect(user: BaseCharacter):
	pass
