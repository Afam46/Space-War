extends "res://scene/bases/boost_base/boost_base.gd"

func apply_boost(player):
	if player.has_method("spawn_feathers"):
		player.spawn_feathers(3)

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)
