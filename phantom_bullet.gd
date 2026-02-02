extends "res://scene/bases/boost_base/boost_base.gd"

func apply_boost(player):
	if player.has_method("make_phantom_bullet"):
		player.make_phantom_bullet()

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)
