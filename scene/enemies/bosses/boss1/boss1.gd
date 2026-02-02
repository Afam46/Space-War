extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var rocket_scene: PackedScene
@export var meteor_scene: PackedScene
var coin_count = 20

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/5
	direction = randf_range(-1,1)
	speed = 200
	speed_h = 200
	hp = 400
	damage = randi_range(15, 30)
	size = 40
	boost_chance = 0
	sound_type = 3
	
func _on_shot_timeout():
	shot()

func shot():
	var rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(84, 138)
	get_parent().add_child(rocket)
	
	rocket = rocket_scene.instantiate()
	rocket.global_position = global_position + Vector2(-84, 138)
	get_parent().add_child(rocket)

func spawn_meteor():
	$Shot.stop()
	$SpawnMeteor.stop()
	var width_screen = get_viewport().get_visible_rect().size.x
	var meteor_position = [
		Vector2(width_screen/10, 0), Vector2(width_screen*6/10, 0),
		Vector2(width_screen*2/10, 0), Vector2(width_screen*7/10, 0), 
		Vector2(width_screen*3/10, 0), Vector2(width_screen*8/10, 0),
		Vector2(width_screen*4/10, 0), Vector2(width_screen*9/10, 0),
		Vector2(width_screen*5/10, 0)
	]
	
	var selected_indices = []
	
	var quantity = randi_range(6, 9)
	
	while selected_indices.size() < quantity:
		var random_index = randi() % meteor_position.size()
		if not selected_indices.has(random_index):
			selected_indices.append(random_index)
	
	for i in range(quantity):
		var meteor = meteor_scene.instantiate()
		meteor.global_position = meteor_position[selected_indices[i]]
		meteor.boost_chance = 0
		get_parent().add_child(meteor)
		
	await get_tree().create_timer(2.5).timeout
	$Shot.start()
	$SpawnMeteor.start()


func _on_spawn_meteor_timeout():
	spawn_meteor()

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
	var boss_id = "boss1"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_meteors"].unlocked = true
