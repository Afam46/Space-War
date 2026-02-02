extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 7

@onready var laser_scene = preload("res://scene//enemies/default/lazer/lazer.tscn")
@onready var rusher_scene = preload("res://scene/enemies/default/rusher/rusher.tscn")

var can_laser_attack = true
var is_attacking = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/2
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 200
	angular_speed = PI/2
	hp = 500
	damage = randi_range(15, 30)
	size = 40
	boost_chance = 0
	sound_type = 3

func _on_attack_timer_timeout():
	if can_laser_attack and not is_attacking:
		start_laser_attack()

func start_laser_attack():
	$AttackTimer.stop()
	is_attacking = true
	can_laser_attack = false
	speed_h = 0
	angular_speed = 0
	
	await get_tree().create_timer(0.5).timeout
	
	var laser1 = laser_scene.instantiate()
	laser1.position = position 
	laser1.rotation = rotation
	var laser2 = laser_scene.instantiate()
	laser2.position = position 
	laser2.rotation = PI/2 + rotation
	
	add_child(laser1)
	add_child(laser2)
	
	await get_tree().create_timer(3).timeout

	laser1.queue_free()
	laser2.queue_free()
	
	direction = 1 if randi() % 2 == 0 else -1
	speed_h = 200
	angular_speed = PI
	is_attacking = false
	can_laser_attack = true
	$AttackTimer.start()

var death = false

func die():
	if death:
		return
	death = true
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
	var boss_id = "boss2"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["laser_bullet"].unlocked = true


func _on_spawn_rusher_timeout():
	var rusher = rusher_scene.instantiate()
	rusher.global_position = Vector2(screen_size.x/6, 0)
	rusher.boost_chance = 0
	get_parent().add_child(rusher)
	
	rusher = rusher_scene.instantiate()
	rusher.global_position = Vector2(screen_size.x*5/6, 0)
	rusher.boost_chance = 0
	get_parent().add_child(rusher)
