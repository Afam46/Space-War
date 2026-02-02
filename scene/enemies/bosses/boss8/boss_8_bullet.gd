extends RigidBody2D

var speed = 600
var damage = randi_range(10, 16)
var freeze_power = 3

func _physics_process(delta):
	var collision = move_and_collide(Vector2.DOWN * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider and collider.has_method("destroy"):
			collider.destroy(damage)
		queue_free()
	
func instant_death():
	queue_free()
	
func destroy(_damage):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
