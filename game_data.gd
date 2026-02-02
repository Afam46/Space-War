extends Node

var player_coins = 100000
var max_hp = 500
var damage_bonus = 0
var boost_time = 10.0
var record_stage = 0
var hp_upgrade_price = 150
var damage_upgrade_price = 1
var boost_time_upgrade_price = 300
var save_path = "user://savegame.save"
var start_stg = 1
var current_max_equiped_priority = 0

var skins = {
	"default": {
		"name": "Стандартный",
		"price": 0,
		"owned": true,
		"locked": false,
		"bullet_scene": "res://scene/player_scenes/bullet/bullet.tscn",
		"icon": "res://aaasets/players/default_player/default_player_fly5.png",
		"animation_name": "default",
		"ability": "-Совершенно обычный корабль",
		"max_freeze_stage": 3,
		"speed": 1000,
		"hp_bonus": 0
	},
	"default_fast": {
		"name": "Fast",
		"price": 300,
		"owned": false,
		"locked": false,
		"bullet_scene": "res://scene/player_scenes/bullet/bullet.tscn",
		"icon": "res://aaasets/players/default_fast_player/default_fast_player_fly5.png",
		"animation_name": "default_fast",
		"ability": "-Совершенно обычный корабль",
		"max_freeze_stage": 3,
		"speed": 1500,
		"hp_bonus": -50
	},
	"default_normal": {
		"name": "Normal",
		"price": 300,
		"owned": false,
		"locked": false,
		"bullet_scene": "res://scene/player_scenes/bullet/bullet.tscn",
		"icon": "res://aaasets/players/default_normal_player/default_normal_player_fly5.png",
		"animation_name": "default_normal",
		"ability": "-Совершенно обычный корабль",
		"max_freeze_stage": 3,
		"speed": 1250,
		"hp_bonus": 50
	},
	"default_bighp": {
		"name": "Fat",
		"price": 300,
		"owned": false,
		"locked": false,
		"bullet_scene": "res://scene/player_scenes/bullet/bullet.tscn",
		"icon": "res://aaasets/players/default_bighp_player/default_bighp_player_fly5.png",
		"animation_name": "default_bighp",
		"ability": "-Совершенно обычный корабль",
		"max_freeze_stage": 3,
		"speed": 750,
		"hp_bonus": 100
	},
	"white": {
		"name": "Белый",
		"price": 500,
		"owned": false,
		"locked": true,
		"bullet_scene": "res://scene/player_scenes/ice_bullet/ice_bullet.tscn",
		"icon": "res://aaasets/players/white_player/white_player_fly5.png",
		"animation_name": "white",
		"ability": "-Ледяные пули \n -Хорошая защита от холода",
		"max_freeze_stage": 6,
		"speed": 1000,
		"hp_bonus": 0
	},
	"ice": {
		"name": "Ледяной",
		"price": 800,
		"owned": false,
		"locked": true,
		"bullet_scene": "res://scene/player_scenes/feather/feather_straight.tscn",
		"icon": "res://aaasets/players/ice_player/ice_player_fly5.png",
		"animation_name": "ice",
		"ability": "-Ледяные пули \n -Отличная защита от холода",
		"max_freeze_stage": 9,
		"speed": 1000,
		"hp_bonus": 0
	},
}

var current_skin = "default"

var rashodniki = {
	"grenade": {
		"name": "Grenade",
		"price": 100,
		"equiped": false,
		"locked": false,
		"quantity": 0,
		"icon": "res://aaasets/items/grenade.png",
		"equiped_priority": 0,
		"ability": "-Grenade"
	},
	"battery": {
		"name": "Батарейка",
		"price": 50,
		"equiped": false,
		"locked": false,
		"quantity": 0,
		"icon": "res://aaasets/items/battery.png",
		"equiped_priority": 0,
		"ability": "-Повышает скорость на 50%, пока игрок не получит урон"
	},
	"hot_oil": {
		"name": "Горячее Масло",
		"price": 50,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/hot_oil.png",
		"equiped_priority": 0,
		"ability": "-Понижает Заморозку \n -Защищает от заморозки дальнейшие 10 секунд"
	},
	"health_kit": {
		"name": "Аптечка",
		"price": 100,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/health_kit.png",
		"equiped_priority": 0,
		"ability": "-Повышает скорость на 50%, пока игрок не получит урон"
	},
	"grenade_green": {
		"name": "Grenade",
		"price": 100,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/grenade_green.png",
		"equiped_priority": 0,
		"ability": "-Grenade Green"
	},
	"fire_extinguisher": {
		"name": "Огнетушитель",
		"price": 75,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/fire_extinguisher.png",
		"equiped_priority": 0,
		"ability": "-Понижает Перегрев \n -Защищает от перегрева дальнейшие 10 секунд"
	},
	"smoke_grenade": {
		"name": "Smoke",
		"price": 100,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/smoke_grenade.png",
		"equiped_priority": 0,
		"ability": "-Smoke"
	},
	"grenade_contact": {
		"name": "Grenade",
		"price": 100,
		"equiped": false,
		"locked": true,
		"quantity": 0,
		"icon": "res://aaasets/items/grenade_contact.png",
		"equiped_priority": 0,
		"ability": "-Grenade Contact"
	},
}

var available_boosts = {
	"res_health": {
		"id" : "0",
		"name": "Усиление здоровья",
		"price": 100,
		"unlocked": false,
		"scene": preload("res://scene/boosts/res_health/res_health.tscn"),
		"icon_path": "res://icons/icon_res_health.png",
		"rare": 0,
		"type": "shop"
	},
	"boost_bullet": {
		"id" : "1",
		"name": "Усиление урона", 
		"price": 150,
		"unlocked": false,
		"scene": preload("res://scene/boosts/boost_bullet/boost_bullet.tscn"),
		"icon_path": "res://icons/icon_boost_damage.png",
		"rare": 0,
		"type": "shop"
	},
	"double_bullet_h": {
		"id" : "2",
		"name": "Двойной выстрел",
		"price": 200,
		"unlocked": false,
		"scene": preload("res://scene/boosts/double_bullet_h/double_bullet_h.tscn"),
		"icon_path": "res://icons/icon_double_bullet_h.png",
		"rare": 0,
		"type": "shop"       
	},
	"double_bullet_v": {
		"id" : "3",
		"name": "Двойной выстрел", 
		"price": 200,
		"unlocked": false,
		"scene": preload("res://scene/boosts/double_bullet_v/double_bullet_v.tscn"),
		"icon_path": "res://icons/icon_double_bullet_v.png",
		"rare": 0,
		"type": "shop"       
	},
	"triple_bullet_h": {
		"id" : "4",
		"name": "Тройной выстрел",
		"price": 1000,
		"unlocked": false,
		"scene": preload("res://scene/boosts/triple_bullet_h/triple_bullet_h.tscn"),
		"icon_path": "res://icons/icon_triple_bullet_h.png",
		"rare": 1,
		"type": "shop"       
	},
	"regen_hp": {
		"id" : "5",
		"name": "Regeneration hp",
		"price": 300,
		"unlocked": false,
		"scene": preload("res://scene/boosts/regen_hp/regen_hp.tscn"),
		"icon_path": "res://icons/icon_regen_hp.png",
		"rare": 1,
		"type": "shop"       
	},
	"spawn_meteors": {
		"id" : "6",
		"name": "Spawn Meteors",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_meteors/spawn_meteors.tscn",
		"icon_path": "res://icons/icon_spawn_meteors.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss1"      
	},
	"laser_bullet": {
		"id" : "7",
		"name": "Laser Bullet",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/laser_bullet/laser_bullet.tscn",
		"icon_path": "res://icons/icon_laser.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss2"      
	},
	"wall_sheald": {
		"id" : "8",
		"name": "Wall Sheald",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/wall_sheald/wall_sheald.tscn",
		"icon_path": "res://icons/icon_sheald.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss3"      
	},
	"boost_magma_bullet": {
		"id" : "9",
		"name": "Magma Bullet",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/boost_magma_bullet/boost_magma_bullet.tscn",
		"icon_path": "res://icons/icon_magma_bullet.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss4"      
	},
	"triple_bullet_rotate": {
		"id" : "10",
		"name": "Triple Bullet Rotate",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/triple_bullet_rotate/triple_bullet_rotate.tscn",
		"icon_path": "res://icons/icon_bullet_rotate.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss5"   
	},
	"spawn_feathers": {
		"id" : "11",
		"name": "Spawn Feathers",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_feather/spawn_feather.tscn",
		"icon_path": "res://icons/icon_spawn_feather.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss6"   
	},
	"spawn_dragon_sheald": {
		"id" : "12",
		"name": "Dragon Sheald",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/dragon_sheald/boost_dragon_sheald.tscn",
		"icon_path": "res://icons/icon_dragon_sheald.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss7"   
	},
	"spawn_companion": {
		"id" : "13",
		"name": "Companion",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_companion/spawn_companion.tscn",
		"icon_path": "res://icons/icon_companion.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss8"   
	},
	"spear_bullet": {
		"id" : "14",
		"name": "Spear Bullet",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spear_bullet/spear_bullet_boost.tscn",
		"icon_path": "res://icons/icon_spear.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss9"   
	},
	"spawn_egg": {
		"id" : "15",
		"name": "Spawn Egg",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_egg/spawn_egg.tscn",
		"icon_path": "res://icons/icon_spawn_egg.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss10"   
	},
	"spawn_lava_balls": {
		"id" : "16",
		"name": "Spawn Lava Balls",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_lava_balls/spawn_lava_balls.tscn",
		"icon_path": "res://icons/icon_lava_balls_spawn.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss11"   
	},
	"spawn_lava_lasers": {
		"id" : "17",
		"name": "Spawn Lava Lasers",
		"price": 0,
		"unlocked": false,
		"scene_path": "res://scene/boosts/spawn_lasers/spawn_lasers.tscn",
		"icon_path": "res://icons/icon_laser.png",
		"rare": 4,
		"type": "boss",
		"boss_owner": "boss12"   
	},
}

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_var(player_coins)
		file.store_var(available_boosts)
		file.store_var(record_stage)
		file.store_var(max_hp)
		file.store_var(damage_bonus)
		file.store_var(boost_time)
		file.store_var(hp_upgrade_price)
		file.store_var(damage_upgrade_price)
		file.store_var(boost_time_upgrade_price)
		file.store_var(start_stg)
		file.store_var(skins)
		file.store_var(current_skin)
		file.store_var(rashodniki)
		file.store_var(current_max_equiped_priority)
		file.close()
		print("Игра сохранена!")

func load_game():
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		if file:
			player_coins = file.get_var()
			available_boosts = file.get_var()
			record_stage = file.get_var()
			max_hp = file.get_var()
			damage_bonus = file.get_var()
			boost_time = file.get_var()
			hp_upgrade_price = file.get_var()
			damage_upgrade_price = file.get_var()
			boost_time_upgrade_price = file.get_var()
			start_stg = file.get_var()
			skins = file.get_var()
			current_skin = file.get_var()
			rashodniki = file.get_var()
			current_max_equiped_priority = file.get_var()
			file.close()
			print("Игра загружена!")
	else:
		print("Файл сохранения не найден")


func clear_save():
	var dir = DirAccess.open("user://")
	if dir.file_exists("savegame.save"):
		dir.remove("savegame.save")
		print("Сохранение очищено!")
	else:
		print("Файл сохранения не найден")

func get_boss_boost(boss_id: String) -> String:
	for boost_id in available_boosts:
		var boost_data = available_boosts[boost_id]
		if boost_data.get("type") == "boss" and boost_data.get("boss_owner") == boss_id:
			return boost_id
	return ""

func unlock_skin(ids):
	for id in ids:
		skins[id].locked = false
	save_game()
	
func unlock_rashodniki(ids):
	for id in ids:
		rashodniki[id].locked = false
	save_game()

func get_equipped_rashodniki() -> Array:
	var list := []
	for id in rashodniki:
		if rashodniki[id].equiped:
			list.append({
				"id": id,
				"priority": rashodniki[id].equiped_priority
			})
	list.sort_custom(func(a, b): return a["priority"] < b["priority"])
	var result := []
	for item in list:
		result.append(item["id"])
	
	return result

func equip_rashodnik(id):
	var count = 0
	for k in rashodniki.keys():
		if rashodniki[k].equiped:
			count += 1
	
	if count >= 3:
		return false

	rashodniki[id].equiped = true
	save_game()
	return true
