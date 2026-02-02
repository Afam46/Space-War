extends "res://scene/bases/enemy_base/enemy_base.gd"

func _ready():
	max_freeze_stage = 1
	$AnimatedSprite2D.play()
	speed = 200
	angular_speed = randf_range(-PI, PI)
	rotate_speed = 400
	hp = 20
	boost_chance = 0
	sound_type = 0

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	rotation += angular_speed * delta
	var velocity = Vector2.DOWN.rotated(rotation) * rotate_speed
	position += velocity * delta

func instant_death():
	super.die()

func _on_life_time_timeout():
	instant_death()
