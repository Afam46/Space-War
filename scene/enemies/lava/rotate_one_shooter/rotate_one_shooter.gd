extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene
var shot_flip = 1 

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 120
	direction = randf_range(-1,1)
	max_freeze_stage = 7
	hp = 120
	speed = 300
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/7, screen_size.y/4)
	coin_chance = 20
	size = 20

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = $SpawnPoint.global_position

	if bullet.has_method("set_direction_from_enemy"):
		bullet.set_direction_from_enemy(rotation)

	get_parent().add_child(bullet)
	var new_rot = (PI/10) * shot_flip

	var tw = create_tween()
	tw.tween_property(self, "rotation", new_rot, 0.2)

	shot_flip *= -1
