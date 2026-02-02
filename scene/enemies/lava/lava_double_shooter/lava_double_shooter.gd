extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 120
	direction = randf_range(-1,1)
	max_freeze_stage = 7
	hp = 150
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 20

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(42,44)
	bullet.set_direction_from_enemy(-PI/10)
	get_parent().add_child(bullet)
	
	bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-42,44)
	bullet.set_direction_from_enemy(PI/10)
	get_parent().add_child(bullet)
