extends "res://scene/bases/enemy_base/enemy_base.gd"
@export var all_boost_scenes: Array[PackedScene] = [] 

func _ready():
	speed = 300
	speed_after_death = 200
	angular_speed = PI
	angular_speed_after_death = PI
	coin_chance = 35

func drop_boost():
	if randf() * 100 <= 5:
		if all_boost_scenes.size() > 0:
			var boost_index = randi_range(0, all_boost_scenes.size() - 1)
			var boost_scene = all_boost_scenes[boost_index]
			var boost = boost_scene.instantiate()
			boost.position =  position
			get_parent().add_child(boost)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
