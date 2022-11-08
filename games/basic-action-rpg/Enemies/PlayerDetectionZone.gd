extends Area2D

var player = null

func _physics_process(delta):
	pass

func can_see_player():
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	player = body

func _on_PlayerDetectionZone_body_exited(body):
	player = null
