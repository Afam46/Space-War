extends Area2D

func _on_body_entered(body):
	if body.has_method("make_player_bullet"):
		body.make_player_bullet()
	elif body.has_method("instant_death"):
		body.instant_death()

func speed_up():
	pass
