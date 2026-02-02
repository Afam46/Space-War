extends RigidBody2D

var speed = 800
var freeze_power = 2
var damage = randi_range(8, 12)
var angular_speed = randf_range(-PI/2, PI/2)
var rotate_speed = 100

func _ready():
	angular_speed = randf_range(-PI/2, PI/2)

func _physics_process(delta):
	rotation += angular_speed * delta
	var direction = Vector2.UP.rotated(rotation)
	var collision = move_and_collide(direction * rotate_speed * delta)
	if collision:
		handle_collision(collision.get_collider())
		queue_free()

func handle_collision(collider):
	if collider:
		if collider.has_method("destroy") and collider.has_method("freeze"):
			collider.freeze(freeze_power)
			collider.destroy(damage)
		elif collider.has_method("destroy"):
			collider.destroy(damage)


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_life_time_timeout():
	queue_free()

func instant_death():
	queue_free()
