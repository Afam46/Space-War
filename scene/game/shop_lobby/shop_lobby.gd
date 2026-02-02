extends Control

func _on_boosts_shop_pressed():
	get_tree().change_scene_to_file("res://scene/game/boost_shop/boost_shop.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scene/game/main_menu/main_menu.tscn")


func _on_skins_shop_pressed():
	get_tree().change_scene_to_file("res://scene/game/skin_shop/skin_shop.tscn")


func _on_rashodniki_pressed():
		get_tree().change_scene_to_file("res://scene/game/rashodniki_shop/rashodniki_shop.tscn")
