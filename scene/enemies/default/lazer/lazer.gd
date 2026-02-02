extends RigidBody2D

var damage = randi_range(10, 15)

func _ready():
	await get_tree().create_timer(3).timeout
	queue_free()

func laser():
	pass
