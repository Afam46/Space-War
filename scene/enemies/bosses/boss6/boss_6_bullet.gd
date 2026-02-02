extends RigidBody2D

var speed = 800
var freeze_power = 2
var damage = randi_range(8, 12)
var angular_speed
var rotate_speed

var max_deviation = 300.0
var deviation_speed = 2.0
var time_passed = 0.0

func _physics_process(delta):
	if angular_speed:
		rotation += angular_speed * delta
		var velocity = Vector2.DOWN.rotated(rotation) * rotate_speed
		move_and_collide(velocity * delta)
	else:
		time_passed += delta
		
		var noise_offset = sin(time_passed * deviation_speed) * cos(time_passed * deviation_speed * 1.3) * max_deviation * delta
		
		var velocity = Vector2(noise_offset, speed * delta)
		move_and_collide(velocity)
	
func instant_death():
	queue_free()
	
func destroy(_damage):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_life_time_timeout():
	instant_death()
