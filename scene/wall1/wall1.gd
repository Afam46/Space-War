extends "res://scene/bases/enemy_base/enemy_base.gd"

func _ready():
	hp = 100
	speed = 300
	speed_after_death = 300

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
