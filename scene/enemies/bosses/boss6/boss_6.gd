extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 15
@onready var bullet_scene = preload("res://scene/enemies/bosses/boss6/boss6_bullet.tscn")
var count_spawn = 0
var back = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/6
	direction = 1 if randi() % 2 == 0 else -1
	speed = 500
	speed_h = 150
	hp = 1400
	damage = randi_range(20, 35)
	size = 120
	boost_chance = 0
	sound_type = 3

func move_h(delta):
	if not back:
		if position.y >= target_y_position:
			speed = 0
			move_and_collide(Vector2.RIGHT * direction * delta * speed_h)

			if position.x >= screen_size.x - size:
				position.x = screen_size.x - size
				direction = -1
			elif position.x <= size:
				position.x = size
				direction = 1
	else:
		if position.y <= target_y_position:
			speed = 0
			move_and_collide(Vector2.RIGHT * direction * delta * speed_h)

			if position.x >= screen_size.x - size:
				position.x = screen_size.x - size
				direction = -1
			elif position.x <= size:
				position.x = size
				direction = 1

func shot():
	for i in range(2):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(randi_range(77, 145), randi_range(20, 80))
		get_parent().add_child(bullet)
	
	for i in range(2):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(randi_range(-145, -77), randi_range(20, 80))
		get_parent().add_child(bullet)

func _on_doodge_timeout():
	doodge()

func _on_dash_timeout():
	dash()

func doodge():
	shot()
	speed_h = 1000
	direction = 1 if randi() % 2 == 0 else -1
	await get_tree().create_timer(0.3).timeout
	speed_h = 150
	shot()
	$Dash.start()
	
func dash():
	back = false
	speed = 1600
	target_y_position = screen_size.y/1.5
	spawn_feather()
	await get_tree().create_timer(0.5).timeout
	spawn_feather()
	spawn_feather()
	speed = -1600
	target_y_position = screen_size.y/6
	back = true
	$Doodge.start()
	
func spawn_feather():
	for i in range(3):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position
		bullet.angular_speed = randf_range(-PI, PI)
		bullet.rotate_speed = randi_range(100, 300)
		get_parent().add_child(bullet)

func hit_anim():
	count_spawn += 1
	super.hit_anim()
	if count_spawn >= 3:
		spawn_feather()
		count_spawn = 0

var death = false

func die():
	if death:
		return
	death = true
	$Doodge.stop()
	$Dash.stop()
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
	var boss_id = "boss6"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_feathers"].unlocked = true
