extends RigidBody2D

var speed = 400
var damage = randi_range(5, 10)
var angular_speed = PI
var direction = randf_range(-1,1)

func _physics_process(delta):
	move_and_collide(Vector2(1 * direction, 1) * delta * speed)
	rotation += angular_speed * delta
	
func instant_death():
	queue_free()
	
func destroy(_damage):
	queue_free()

func destroy_player_bullet():
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
