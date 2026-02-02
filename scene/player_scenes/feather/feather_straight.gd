extends RigidBody2D

var speed = 800
var freeze_power = 2
var damage = randi_range(10, 16)

var wave_amplitude = 60.0
var wave_speed = 8.0
var time_passed = 0.0

var direction := Vector2.UP

func _physics_process(delta):
	time_passed += delta
	var side = direction.orthogonal().normalized()
	var wave_offset = side * sin(time_passed * wave_speed) * wave_amplitude
	var velocity = direction * speed + wave_offset
	var collision = move_and_collide(velocity * delta)
	if collision:
		handle_collision(collision.get_collider())
		queue_free()

func handle_collision(collider):
	if collider:
		if collider.has_method("freeze"):
			collider.freeze(freeze_power)
		if collider.has_method("destroy"):
			collider.destroy(damage)

func set_direction_from_enemy(rot):
	rotation = rot
	direction = Vector2.DOWN.rotated(rot).normalized()

func set_direction_from_player(rot):
	rotation = rot
	direction = Vector2.UP.rotated(rot).normalized()
