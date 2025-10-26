extends "res://scene/bases/enemy_base/enemy_base.gd"

func _ready():
	$AnimatedSprite2D.play()
	speed = 200
	angular_speed = randf_range(-PI,PI)
	rotate_speed = 400
	hp = 2
	
func instant_death():
	super.die()

func _on_life_time_timeout():
	instant_death()
