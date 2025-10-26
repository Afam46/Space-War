extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

var shot_kd = randf_range(0, 2)

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 100
	target_y_position = randf_range(100, 400)
	direction = randf_range(-1,1)
	hp = 2
	speed = 300
	screen_size = get_viewport_rect().size
	coin_chance = 20
	size = 20

func _on_shot_timeout():
	shot()

func shot():
	await get_tree().create_timer(shot_kd).timeout
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 62)
	get_parent().add_child(bullet)
	bullet.get_node("AnimatedSprite2D").animation = "fly"
	await get_tree().create_timer(0.5).timeout
	if is_instance_valid(bullet):
		bullet.get_node("AnimatedSprite2D").animation = "idle"
