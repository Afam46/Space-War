extends "res://scene/bases/boost_base/boost_base.gd"

func apply_boost(player):
	if player.has_method("spawn_meteors"):
		player.spawn_meteors()

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)

func on_pickup():
	var boost_id = "spawn_meteors"
	GameData.unlock_boss_boost(boost_id)
	queue_free()
