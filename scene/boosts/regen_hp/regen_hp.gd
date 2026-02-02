extends "res://scene/bases/boost_base/boost_base.gd"

var health_regen: int = 10

func apply_boost(player):
	if player.has_method("regen_health"):
		player.regen_health(health_regen)

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)
