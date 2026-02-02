extends Area2D

func _on_body_entered(body):
	if body and body.has_method("destroy"):
		body.destroy(30)
