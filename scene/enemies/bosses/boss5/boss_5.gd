extends "res://scene/bases/enemy_base/enemy_base.gd"

var coin_count = 12
var isDetach = false
@export var ice_bullet_scene: PackedScene
@onready var head_instance = $Boss5Head

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/6
	direction = 1 if randi() % 2 == 0 else -1
	speed = 150
	speed_h = 100
	hp = 1000
	damage = randi_range(20, 35)
	size = 40
	boost_chance = 0
	sound_type = 3

func destroy(player_damage):
	hp -= player_damage
	if not isDetach and head_instance:
		head_instance.call_deferred("hit_red_anim")
	if hp <= 350 and head_instance and head_instance.get_parent() == self:
		detach_head()
	
	super.destroy(player_damage)

func detach_head():
	isDetach = true
	if head_instance and head_instance.get_parent() == self:
		if head_instance.get_node("CollisionShape2D"):
			head_instance.get_node("CollisionShape2D").set_deferred("disabled", false)
		remove_child(head_instance)
		get_parent().add_child(head_instance)
		head_instance.global_position = global_position + Vector2(0, 114)
		head_instance.speed = 400
		head_instance.set_as_top_level(true)
		
		if head_instance.has_method("activate_head_movement"):
			head_instance.activate_head_movement()
		if head_instance.has_node("AnimatedSprite2D"):
			head_instance.get_node("AnimatedSprite2D").play("fly")
		if head_instance.has_node("Shot"):
			head_instance.get_node("Shot").start()

func _on_shot_timeout():
	shot()

func shot():
	var bullet_positions = [
		{"pos": Vector2(68, 146), "rot": 0},
		{"pos": Vector2(54, 146), "rot": PI/4},
		{"pos": Vector2(82, 146), "rot": -PI/4},
		{"pos": Vector2(-68, 146), "rot": 0},
		{"pos": Vector2(-54, 146), "rot": -PI/4},
		{"pos": Vector2(-82, 146), "rot": PI/4}
	]
	
	for bullet_data in bullet_positions:
		var ice_bullet = ice_bullet_scene.instantiate()
		ice_bullet.global_position = global_position + bullet_data["pos"]
		ice_bullet.set_direction_from_enemy(bullet_data["rot"])
		get_parent().add_child(ice_bullet)

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
	var boss_id = "boss5"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["triple_bullet_rotate"].unlocked = true
