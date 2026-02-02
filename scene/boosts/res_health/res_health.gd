extends "res://scene/bases/boost_base/boost_base.gd"

@export var heal_amount: int = 25

func apply_boost(player):
	if player.has_method("res_health"):
		player.res_health(heal_amount)

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)
