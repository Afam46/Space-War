extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var magma_bullet_scene: PackedScene
@export var magma_shooter_scene: PackedScene
var coin_count = 10

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/6
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 200
	hp = 500
	damage = randi_range(15, 30)
	size = 40
	boost_chance = 0
	sound_type = 3

func _on_shot_timeout():
	shot()

func shot():
	var magma_bullet = magma_bullet_scene.instantiate()
	magma_bullet.global_position = global_position + Vector2(0, 130)
	get_parent().add_child(magma_bullet)

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
	var boss_id = "boss4"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["boost_magma_bullet"].unlocked = true

func _on_spawn_one_shooter_timeout():
	var magma_shooter = magma_shooter_scene.instantiate()
	magma_shooter.global_position = Vector2(screen_size.x/6, 0)
	magma_shooter.boost_chance = 0
	get_parent().add_child(magma_shooter)
	
	magma_shooter = magma_shooter_scene.instantiate()
	magma_shooter.global_position = Vector2(screen_size.x*5/6, 0)
	magma_shooter.boost_chance = 0
	get_parent().add_child(magma_shooter)
