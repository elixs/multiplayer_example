extends CharacterBody2D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree["parameters/playback"]
@onready var label: Label = $Label

func setup(player_data: Statics.PlayerData):
	label.name = player_data.name
