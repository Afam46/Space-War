extends "res://scene/bases/enemy_base/enemy_base.gd"

func _ready():
	$AnimatedSprite2D.play()
	speed_h = 100
	direction = randf_range(-1,1)
	hp = 100
	speed = 100
	screen_size = get_viewport_rect().size
	target_y_position = randi_range(screen_size.y/5, screen_size.y/3)
	coin_chance = 30
	size = 40
