extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_ice_bullet_scene: PackedScene

var shot_kd = randf_range(0, 2)

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 200
	direction = randf_range(-1,1)
	hp = 160
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 40
	size = 40
	sound_type = 2

func _on_shot_timeout():
	shot()

func shot():
	await get_tree().create_timer(shot_kd).timeout
	var bullet = enemy_ice_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(72, 70)
	bullet.set_direction_from_enemy(-PI/10)
	get_parent().add_child(bullet)
	
	bullet = enemy_ice_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(52, 70)
	bullet.set_direction_from_enemy(PI/10)
	get_parent().add_child(bullet)

	bullet = enemy_ice_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-72, 70)
	bullet.set_direction_from_enemy(PI/10)
	get_parent().add_child(bullet)
	
	bullet = enemy_ice_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-52, 70)
	bullet.set_direction_from_enemy(-PI/10)
	get_parent().add_child(bullet)
