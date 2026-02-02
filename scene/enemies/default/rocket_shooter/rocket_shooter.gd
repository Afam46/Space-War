extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var rocket_scene: PackedScene

var shot_kd = randf_range(0, 2)

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 100
	direction = randf_range(-1,1)
	hp = 50
	speed = 200
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 30

func _on_shot_timeout():
	shot()

func shot():
	await get_tree().create_timer(shot_kd).timeout
	var rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(0, 124)
	get_parent().add_child(rocket)
