extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var lava_laser_for_lvl_scene: PackedScene
@export var electro_ball_boost_scene: PackedScene
var coin_count = 15

func _ready():
	$AnimatedSprite2D.play()
	$AnimatedSprite2D2.play()
	screen_size = get_viewport_rect().size
	position.x = screen_size.x/2
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	hp = 20000
	damage = randi_range(30, 50)
	boost_chance = 0
	sound_type = 2

func _on_spawn_electro_ball_boost_timeout():
	var electro_ball_boost = electro_ball_boost_scene.instantiate()
	electro_ball_boost.global_position = Vector2(screen_size.x/2, 0)
	get_parent().add_child(electro_ball_boost)

func _on_spawn_lava_lasers_lvl_timeout():
	var variant = randi_range(0, 3)
	var anim_name = "use_comp1" if variant > 1 else "use_comp2"

	$AnimatedSprite2D.play(anim_name)
	$AnimatedSprite2D.sprite_frames.set_animation_loop(anim_name, false)
	
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.play("fly")
	
	spawn_laser_lvl(variant)

func spawn_laser_lvl(variant: int):
	if variant == 0:
		spawn_lvl0()
	elif variant == 1:
		spawn_lvl1()
	elif variant == 2:
		spawn_lvl2()
	else:
		spawn_lvl3()

func spawn_lvl0():
	var lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/3, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/3, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1.5).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/2, 0)
	get_parent().add_child(lava_laser)

func spawn_lvl1():
	var lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	lava_laser.rotation = -PI/4
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	lava_laser.rotation = PI/4
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1.5).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/3, 0)
	lava_laser.rotation = PI/4
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/3, 0)
	lava_laser.rotation = -PI/4
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1.5).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	lava_laser.rotation = -PI/4
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	lava_laser.rotation = PI/4
	get_parent().add_child(lava_laser)

func spawn_lvl2():
	var lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	lava_laser.rotation = -PI/4
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	lava_laser.rotation = PI/4
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/3, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/3, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	lava_laser.rotation = PI/4
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	lava_laser.rotation = -PI/4
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(1).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/2, 0)
	get_parent().add_child(lava_laser)

func spawn_lvl3():
	var lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/6, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/1.8, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/2.5, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/12, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	await get_tree().create_timer(2).timeout
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x - screen_size.x/6, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/1.8, 0)
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/2.5, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)
	
	lava_laser = lava_laser_for_lvl_scene.instantiate()
	lava_laser.global_position = Vector2(screen_size.x/12, 0)
	lava_laser.rotation = PI/2
	get_parent().add_child(lava_laser)

func laser():
	pass

var death = false

func die():
	if death:
		return
	death = true
	$SpawnElectroBallBoost.stop()
	super.die()
	call_deferred("drop_coins") 
	call_deferred("drop_boss_boost") 

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
	var boss_id = "boss12"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_lava_lasers"].unlocked = true

func destroy(player_damage):
	if player_damage < 5000:
		return
		
	super.destroy(player_damage)
