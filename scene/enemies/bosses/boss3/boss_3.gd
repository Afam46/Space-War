extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 15
var rusher_scene= preload("res://scene/enemies/default/rusher/rusher.tscn")
var electro_scene= preload("res://scene/enemies/default/electro_shooter/electro_shooter.tscn")
var one_scene= preload("res://scene/enemies/default/one_shooter/one_shooter.tscn")
var double_scene= preload("res://scene/enemies/default/double_shooter/double_shooter.tscn")
var rocket_shooter_scene = preload("res://scene/enemies/default/rocket_shooter/rocket_shooter.tscn")

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = randf_range(-1,1)
	speed = 200
	speed_h = 100
	hp = 150
	damage = randi_range(15, 30)
	size = 40
	boost_chance = 0
	sound_type = 3

func destroy(player_damage):
	start_shake()
	super.destroy(player_damage)

var death = false

func die():
	if death:
		return
	death = true
	super.die()
	call_deferred("drop_coins") 
	call_deferred("drop_boss_boost") 
	call_deferred("spawn_enemies")

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
	var boss_id = "boss3"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["wall_sheald"].unlocked = true

func spawn_enemies():
	var rusher = rusher_scene.instantiate()
	rusher.global_position = global_position
	rusher.boost_chance = 0
	get_parent().add_child(rusher)
	
	var electro = electro_scene.instantiate()
	electro.global_position = global_position
	electro.boost_chance = 0
	get_parent().add_child(electro)
	
	electro = electro_scene.instantiate()
	electro.global_position = global_position
	electro.boost_chance = 0
	get_parent().add_child(electro)
	
	var one = one_scene.instantiate()
	one.global_position = global_position
	one.boost_chance = 0
	get_parent().add_child(one)
	
	var double = double_scene.instantiate()
	double.global_position = global_position
	double.boost_chance = 0
	get_parent().add_child(double)
	
	var rocket = rocket_shooter_scene.instantiate()
	rocket.global_position = global_position
	rocket.boost_chance = 0
	get_parent().add_child(rocket)

func start_shake():
	var original_position = position
	var shake_strength = 5.0
	var shake_duration = 0.3
	
	var tween = create_tween()
	tween.set_loops(3)
	
	tween.tween_property(self, "position", original_position + Vector2(shake_strength, 0), shake_duration / 6)
	tween.tween_property(self, "position", original_position + Vector2(-shake_strength, 0), shake_duration / 6)
	tween.tween_property(self, "position", original_position + Vector2(0, shake_strength), shake_duration / 6)
	tween.tween_property(self, "position", original_position + Vector2(0, -shake_strength), shake_duration / 6)
	tween.tween_property(self, "position", original_position, shake_duration / 6)
