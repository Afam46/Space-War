extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 10
@export var spear_scene: PackedScene
@export var lava_laser_scene: PackedScene
var back = false
var noRotate = true

const SPEAR_OFFSETS = [
	Vector2(0, 202),
	Vector2(164, 146),
	Vector2(-164, 146)
]

const REVERSE_SPEAR_OFFSETS = [
	Vector2(0, -202),
	Vector2(164, -146),
	Vector2(-164, -146)
]

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 200
	hp = 2000
	damage = randi_range(30, 50)
	size = 120
	boost_chance = 0
	sound_type = 3

func move_h(delta):
	if (not back and position.y >= target_y_position) \
	or (back and position.y <= target_y_position):

		speed = 0
		move_and_collide(Vector2.RIGHT * direction * speed_h * delta)

		if position.x >= screen_size.x - size:
			position.x = screen_size.x - size
			direction = -1
		elif position.x <= size:
			position.x = size
			direction = 1

func laser():
	pass

func _on_spear_shot_timeout():
	spear_shot()
	
func _on_reverse_spear_shot_timeout():
	reverse_spear_shot()

func spear_shot():
	var spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(0, 202)
	get_parent().add_child(spear)

	spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(164, 146)
	spear.set_direction_from_enemy(PI/10)
	get_parent().add_child(spear)
	
	spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(-164, 146)
	spear.set_direction_from_enemy(-PI/10)
	get_parent().add_child(spear)

func reverse_spear_shot():
	var spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(0, -202)
	spear.set_direction_from_reverse_enemy(0)
	spear.get_node("Sprite2D").rotation = 0
	get_parent().add_child(spear)

	spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(164, -146)
	spear.set_direction_from_reverse_enemy(-PI/10)
	spear.get_node("Sprite2D").rotation = 0
	get_parent().add_child(spear)
	
	spear = spear_scene.instantiate()
	spear.global_position = global_position + Vector2(-164, -146)
	spear.set_direction_from_reverse_enemy(PI/10)
	spear.get_node("Sprite2D").rotation = 0
	get_parent().add_child(spear)

func _on_dash_timeout():
	dash()

func dash():
	back = false
	speed_h = 400
	speed = 1000
	target_y_position = screen_size.y * 0.5

	await get_tree().create_timer(2).timeout
	$SpearShot.stop()
	mini_dash()
	await get_tree().create_timer(2).timeout
	mini_dash(true)
	await get_tree().create_timer(2).timeout

func mini_dash(rot = false):
	noRotate = true
	speed_h = 0
	back = false
	speed = 800
	target_y_position = screen_size.y/1.2
	await get_tree().create_timer(0.5).timeout
	if rot:
		reverse_mode()
	if noRotate:
		return_to_center()

func return_to_top():
	speed = -1000
	target_y_position = screen_size.y/5
	back = true
	speed_h = 400
	$Dash.start()
	$SpearShot.start()

func return_to_center():
	speed = -800
	target_y_position = screen_size.y/2
	back = true
	direction = 1 if randi() % 2 == 0 else -1
	speed_h = 400

func reverse_mode():
	noRotate = false
	speed_h = 200
	direction = 1 if randi() % 2 == 0 else -1
	$ReverseSpearShot.start()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", PI, 1)
	await get_tree().create_timer(8).timeout
	$ReverseSpearShot.stop()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0, 1)
	return_to_top()

func spawn_lava_laser():
	var width_screen = get_viewport().get_visible_rect().size.x
	var lava_laser_position = [
		Vector2(width_screen/10, 0), Vector2(width_screen*7/10, 0), 
		Vector2(width_screen*3/10, 0),Vector2(width_screen*9/10, 0),
		Vector2(width_screen*5/10, 0)
	]
	
	var selected_indices = []
	
	var quantity = randi_range(3, 5)
	
	while selected_indices.size() < quantity:
		var random_index = randi() % lava_laser_position.size()
		if not selected_indices.has(random_index):
			selected_indices.append(random_index)
	
	for i in range(quantity):
		var lava_laser = lava_laser_scene.instantiate()
		lava_laser.global_position = lava_laser_position[selected_indices[i]]
		lava_laser.boost_chance = 0
		get_parent().add_child(lava_laser)

func _on_spawn_lava_laser_timeout():
	spawn_lava_laser()

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
	var boss_id = "boss9"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spear_bullet"].unlocked = true
