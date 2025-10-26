extends "res://scene/bases/boost_base/boost_base.gd"

func _ready():
	$AnimatedSprite2D.play()
	speed = 100
	area_entered.connect(_on_area_entered)
	
func use_boost(player):
	player.make_double_bullet()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
