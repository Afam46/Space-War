extends "res://scene/bases/enemy_base/enemy_base.gd"

var rand_angular_speed
var freeze_power = 3
var is_forming = true
		
func _ready():
	hp = 50
	coin_chance = 35
	speed = 300
	speed_after_death = 200
	rand_angular_speed = randf_range(PI/8, PI)
	angular_speed = rand_angular_speed
	angular_speed_after_death = rand_angular_speed

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	rotation += angular_speed * delta

func instant_death():
	super.die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_owner_died():
	queue_free()

func die():
	if is_dead:
		return
	is_dead = true
	
	is_forming = false
	
	$Death.play()
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	$AnimatedSprite2D.animation = "death"
	$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
	$AnimatedSprite2D.play()

	speed = speed_after_death
	speed_h = 0
	angular_speed = angular_speed_after_death
	rotate_speed = rotate_speed_after_death

	if coin_scene:
		call_deferred("drop_coin")

	drop_boost()

	await $AnimatedSprite2D.animation_finished
	queue_free()

func play_hit_sound():
	pass
