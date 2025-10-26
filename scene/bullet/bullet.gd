extends RigidBody2D

var speed = 600
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var collision = move_and_collide(Vector2.UP * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider:
			if collider.has_method("destroy"):
				collider.destroy()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
