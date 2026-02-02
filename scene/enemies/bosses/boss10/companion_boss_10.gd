extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var enemy_bullet_scene: PackedScene

func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()
	speed_h = 100
	target_y_position = screen_size.y/2
	direction = randf_range(-1,1)
	hp = 20
	speed = 300
	size = 20
	boost_chance = 0

func _on_shot_timeout():
	shot()

func shot():
	var bullet = enemy_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 38)
	bullet.direction = 0
	bullet.damage = randi_range(8, 12)
	get_parent().add_child(bullet)

func _on_area_2d_body_entered(body):
	if body and body.has_method("destroy"):
		body.destroy(5)
		super.die()
