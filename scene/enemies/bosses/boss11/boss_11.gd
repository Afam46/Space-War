extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var bullet_scene: PackedScene
@export var lava_ball_scene: PackedScene
@export var lava_crab_scene: PackedScene
var coin_count = 14
var lava_ball_count = 3
var isAngry = false
var death = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 120
	hp = 2200
	damage = randi_range(30, 50)
	size = 120
	boost_chance = 0
	sound_type = 3

func make_angry():
	$AnimatedSprite2D.play("fly")
	isAngry = true
	$Shot.stop()
	$LavaBallShot.stop()
	$Shot.start(2)
	$LavaBallShot.start(4)
	$SpawnLavaCrab.start()
	speed_h = 300

func hit_anim():
	super.hit_anim()
	if not isAngry:
		if hp <= 1100:
			make_angry()

func on_spawn_lava_crab_timeout():
	spawn_lava_crab()

func spawn_lava_crab():
	var lava_crab = lava_crab_scene.instantiate()
	get_parent().add_child(lava_crab)
	lava_crab.global_position = Vector2(screen_size.x*5/6, 0)
	lava_crab.boost_chance = 0
	
	lava_crab = lava_crab_scene.instantiate()
	get_parent().add_child(lava_crab)
	lava_crab.global_position = Vector2(screen_size.x/6, 0)
	lava_crab.boost_chance = 0

func on_shot_timeout():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-102, 162)
	get_parent().add_child(bullet)
	
	bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(102, 162)
	get_parent().add_child(bullet)
	
	if isAngry:
		bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(-42, 174)
		get_parent().add_child(bullet)
		
		bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + Vector2(42, 174)
		get_parent().add_child(bullet)

func _on_lava_ball_shot_timeout():
	lava_ball_shot()
	if isAngry and not death:
		await  get_tree().create_timer(1).timeout
		lava_ball_shot()

func lava_ball_shot():
	for i in range(lava_ball_count):
		var lava_ball = lava_ball_scene.instantiate()
		
		var angle = randf() * 2 * PI
		var distance = randf_range(20, 80)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		lava_ball.global_position = global_position + offset
		
		if lava_ball is RigidBody2D:
			lava_ball.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100, 200)
		
		lava_ball.boost_chance = 0
		get_parent().add_child(lava_ball)

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
	var boss_id = "boss11"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_lava_balls"].unlocked = true
