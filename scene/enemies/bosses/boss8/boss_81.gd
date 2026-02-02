extends "res://scene/bases/enemy_base/enemy_base.gd"

signal enemy_died
var coin_count = 7
@export var boss82: PackedScene
@export var boss8_bullet_scene: PackedScene
var boss82_instance: Node2D
var detach_weapons = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 200
	hp = 1000
	damage = randi_range(20, 35)
	size = 80
	boost_chance = 0
	$WeaponBoss812.get_node("AnimatedSprite2D").scale.x = -4
	spawn_boss82()
	sound_type = 3

func spawn_boss82():
	if boss82:
		boss82_instance = boss82.instantiate()
		boss82_instance.global_position = global_position + Vector2(250, 0)
		get_parent().add_child(boss82_instance)

func hit_anim():
	if not detach_weapons:
		if hp <= 250:
			call_deferred("move_weapons_to_parent")
		else:
			$WeaponBoss812.hit_red_anim()
			$WeaponBoss81.hit_red_anim()
	super.hit_anim()

func move_weapons_to_parent():
	detach_weapons = true
	speed_h = 100
	speed = 0
	var parent = get_parent()
	
	if has_node("WeaponBoss812") and parent:
		var weapon1 = $WeaponBoss812
		remove_child(weapon1)
		parent.call_deferred("add_child", weapon1)
		weapon1.global_position = global_position
		weapon1.use_rockets()
	
	if has_node("WeaponBoss81") and parent:
		var weapon2 = $WeaponBoss81  
		remove_child(weapon2)
		parent.call_deferred("add_child", weapon2)
		weapon2.global_position = global_position
		weapon2.use_rockets()
		
var death = false

func die():
	if death:
		return
	death = true
	super.die()
	call_deferred("drop_coins") 
	call_deferred("drop_boss_boost") 
	enemy_died.emit()


func drop_coins():
	for i in range(coin_count):
		var coin = coin_scene.instantiate()
		
		var angle = randf() * 2 * PI
		var distance = randf_range(20, 80)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		coin.global_position = global_position + offset
		
		if coin is RigidBody2D:
			coin.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100, 200)
		
		get_parent().add_child(coin)

func drop_boss_boost():
	var boss_id = "boss8"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_companion"].unlocked = true


func _on_shot_timeout():
	shot()
	
func shot():
	var bullet = boss8_bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, 114)
	get_parent().add_child(bullet)
