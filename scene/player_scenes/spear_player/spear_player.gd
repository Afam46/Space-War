extends RigidBody2D

var speed = 500
var initial_damage = randi_range(25, 40) + GameData.damage_bonus
var damage = initial_damage
var direction = Vector2.UP
var life_time = 2.5
var elapsed_time = 0.0

var is_falling = false
var angular_speed = 0.0
const FALL_SPEED = 200.0
const MIN_FLIGHT_SPEED = 200.0
const MIN_DAMAGE = 5

func _physics_process(delta):
	elapsed_time += delta
	
	if not is_falling:
		var life_ratio = 1.0 - min(elapsed_time / life_time, 1.0)
		
		speed = max(500 * life_ratio, MIN_FLIGHT_SPEED)
		damage = max(initial_damage * life_ratio, MIN_DAMAGE)
		
		if life_ratio < 0.3:
			is_falling = true
			angular_speed = randf_range(-PI/4, PI/4)
	
	if is_falling:
		rotation += angular_speed * delta

	var collision
	if is_falling:
		collision = move_and_collide(direction * FALL_SPEED * delta)
	else:
		collision = move_and_collide(direction * speed * delta)
	
	if collision:
		var collider = collision.get_collider()
		if collider and collider.has_method("destroy"):
			collider.destroy(int(damage))
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy(_damage):
	queue_free()

func set_direction_from_player(rot):
	rotation = rot
	direction = Vector2.UP.rotated(rot)
