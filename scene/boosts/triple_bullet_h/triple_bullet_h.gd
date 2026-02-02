extends "res://scene/bases/boost_base/boost_base.gd"

func apply_boost(player):
	if player.has_method("triple_bullet_h"):
		player.triple_bullet_h()

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)
