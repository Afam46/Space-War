extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

var shot_kd = randf_range(0, 2)

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 150
	direction = randf_range(-1,1)
	hp = 80
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 20

func _on_shot_timeout():
	shot()

func shot():
	await get_tree().create_timer(shot_kd).timeout
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 94)
	get_parent().add_child(bullet)
