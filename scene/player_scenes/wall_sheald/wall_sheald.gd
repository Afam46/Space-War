extends Area2D

func _on_body_entered(body):
	if body.has_method("instant_death"):
		body.instant_death()
	elif body.has_method("destroy"):
		body.destroy(5)

func speed_up():
	pass
