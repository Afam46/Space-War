extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var bullet_scene: PackedScene
@export var lava_ball_scene: PackedScene
@export var lava_egg_scene: PackedScene
var coin_count = 12
var isLowHp = false

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 120
	hp = 2000
	damage = randi_range(30, 50)
	size = 120
	boost_chance = 0
	sound_type = 3
	
func _on_shot_timeout():
	shot()

func shot():
	var offsets = [
		Vector2(138, 104),   # 1
		Vector2(66, 112),    # 2
		Vector2(34, 164),    # 3
		Vector2(0, 196),     # 4 — центральная
		Vector2(-34, 164),   # 5
		Vector2(-66, 112),   # 6
		Vector2(-138, 104)   # 7
	]

	var angles = [
		-PI/10,
		-PI/12,
		-PI/16,
		0,
		PI/16,
		PI/12,
		PI/10
	]

	for i in range(offsets.size()):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + offsets[i]
		bullet.set_direction_from_enemy(angles[i])
		get_parent().add_child(bullet)
		await get_tree().create_timer(0.2).timeout
		
	await get_tree().create_timer(1).timeout
	shot_reverse()

func shot_reverse():
	var offsets = [
		Vector2(138, 104),
		Vector2(66, 112),
		Vector2(34, 164),
		Vector2(0, 196),
		Vector2(-34, 164),
		Vector2(-66, 112),
		Vector2(-138, 104)
	]

	var angles = [
		-PI/10,
		-PI/12,
		-PI/16,
		0,
		PI/16,
		PI/12,
		PI/10
	]

	for i in range(offsets.size() - 1, -1, -1):
		var bullet = bullet_scene.instantiate()
		bullet.global_position = global_position + offsets[i]
		bullet.set_direction_from_enemy(angles[i])
		get_parent().add_child(bullet)
		await get_tree().create_timer(0.2).timeout

func _on_lava_ball_shot_timeout():
	lava_ball_shot()

func lava_ball_shot():
	var lava_ball = lava_ball_scene.instantiate()
	lava_ball.global_position = global_position + Vector2(0, 208)
	lava_ball.boost_chance = 0
	get_parent().add_child(lava_ball)

func _on_spawn_egg_timeout():
	lava_egg_spawn()

func lava_egg_spawn():
	var lava_egg = lava_egg_scene.instantiate()
	lava_egg.global_position = global_position
	lava_egg.boost_chance = 0
	get_parent().add_child(lava_egg)

func hit_anim():
	super.hit_anim()
	
	if not isLowHp:
		if hp <= 350:
			isLowHp = true
			$SpawnEgg.stop()
			$SpawnEgg.start(3)
			speed_h = 300

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
	var boss_id = "boss10"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_egg"].unlocked = true
