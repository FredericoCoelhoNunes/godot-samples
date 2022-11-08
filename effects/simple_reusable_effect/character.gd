extends KinematicBody2D

const Effect = preload("res://Effects/effect.tscn")

func create_effect():
	var effect = Effect.instance()
	get_parent().add_child(effect)
	effect.global_position = global_position
