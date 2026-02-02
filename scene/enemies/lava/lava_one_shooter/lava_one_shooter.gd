extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 120
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	direction = randf_range(-1,1)
	max_freeze_stage = 7
	hp = 120
	speed = 400
	coin_chance = 20
	size = 20
	damage = randi_range(25,35)

func hit_anim():
	if hp <= 50:
		speed = 500
		target_y_position = 0
		speed_h = 0
	super.hit_anim()

func _on_shot_timeout():
	shot()

func instant_death():
	super.die()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 96)
	get_parent().add_child(bullet)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
