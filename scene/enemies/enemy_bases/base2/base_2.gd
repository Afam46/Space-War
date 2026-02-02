extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var all_enemy_scenes: Array[PackedScene] = []
@export var spawn_points: Array[NodePath]
@export var meteor_scene: PackedScene
@export var brilliant_scene: PackedScene
var coin_count = 10
var brilliant_count = 4
var unlock_skins = ["white", "ice"]
var unlock_rashodniks = ["grenade_contact", "fire_extinguisher", "smoke_grenade"]

func _ready():
	hp = 2500
	speed = 100
	screen_size = get_viewport_rect().size
	position.x = screen_size.x/2
	position.y = -300
	target_y_position = screen_size.y / 4
	sound_type = 3
	
func _on_first_spawn_timer_timeout():
	spawn_enemies()

func _on_spawn_timer_timeout():
	spawn_enemies()

func spawn_enemies():
	for spawn_path in spawn_points:
		var spawn = get_node(spawn_path)
		var random_enemy_scene = all_enemy_scenes[randi() % all_enemy_scenes.size()]
		var enemy = random_enemy_scene.instantiate()
		enemy.global_position = spawn.global_position
		get_parent().add_child(enemy)

func spawn_meteor():
	var width_screen = get_viewport().get_visible_rect().size.x
	var meteor_position = [
		Vector2(width_screen/10, 0), Vector2(width_screen*6/10, 0),
		Vector2(width_screen*2/10, 0), Vector2(width_screen*7/10, 0), 
		Vector2(width_screen*3/10, 0), Vector2(width_screen*8/10, 0),
		Vector2(width_screen*4/10, 0), Vector2(width_screen*9/10, 0),
		Vector2(width_screen*5/10, 0)
	]
	
	var selected_indices = []
	
	var quantity = 9
	
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


func _on_spawn_meteor_timeout():
	spawn_meteor()

var is_death = false

func die():
	if is_death:
		return
	is_death = true
	
	if GlobalShake:
		GlobalShake.start_shake(10.0, 5)
	
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	speed_h = 0
		
	drop_coins()
	drop_billiants()
	
	GameData.unlock_skin(unlock_skins)
	GameData.unlock_rashodniki(unlock_rashodniks)
	
	await $AnimatedSprite2D.animation_finished
	queue_free()

func drop_currency(scene, count):
	for i in range(count):
		var coin = scene.instantiate()
		
		var angle = randf() * 2 * PI
		var distance = randf_range(20, 80)
		
		var offset = Vector2(cos(angle), sin(angle)) * distance
		coin.global_position = global_position + offset

		if coin is RigidBody2D:
			coin.linear_velocity = Vector2(cos(angle), sin(angle)) * randf_range(100, 200)
		
		get_parent().add_child(coin)

func drop_coins():
	drop_currency(coin_scene, coin_count)

func drop_billiants():
	drop_currency(brilliant_scene, brilliant_count)
