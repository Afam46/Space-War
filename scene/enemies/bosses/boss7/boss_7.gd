extends "res://scene/bases/enemy_base/enemy_base.gd"

@export var ice_scene: PackedScene
var coin_count = 17

signal tail_shot
signal tail_sheald

func _ready():
	$AnimatedSprite2D.play()
	screen_size = get_viewport_rect().size
	target_y_position = screen_size.y/3
	direction = 1 if randi() % 2 == 0 else -1
	speed = 200
	speed_h = 200
	hp = 1600
	damage = 20
	size = 140
	boost_chance = 0
	sound_type = 3
	
func _on_shot_timeout():
	shot()

func shot():
	var ice = ice_scene.instantiate()
	ice.global_position = global_position + Vector2(118, 44)
	get_parent().add_child(ice)
	
	ice = ice_scene.instantiate()
	ice.global_position = global_position + Vector2(-118, 44)
	get_parent().add_child(ice)

var death = false

func die():
	if death:
		return
	death = true
	
	if has_node("Tail"):
		$Tail.queue_free()
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
	var boss_id = "boss7"
	var boost_id = GameData.get_boss_boost(boss_id)
	
	if boost_id != "":
		var boost_data = GameData.available_boosts[boost_id]
		var boost_scene = load(boost_data["scene_path"])
		
		if boost_scene:
			var boost = boost_scene.instantiate()
			boost.position = global_position
			get_parent().add_child(boost)
			GameData.available_boosts["spawn_dragon_sheald"].unlocked = true


func _on_tail_shot_timeout():
	tail_shot.emit()

func hit_anim():
	if $Tail:
		$Tail.hit_anim()
	super.hit_anim()


func _on_use_sheald_timeout():
	use_sheald()

func use_sheald():
	$TailShot.stop()
	$Shot.stop()
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", PI, 0.4)
	await tween.finished
	tail_sheald.emit()
	
	await get_tree().create_timer(4).timeout
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "rotation", 0.0, 0.4)
	await tween.finished
	$UseSheald.start()
	$TailShot.start()
	$Shot.start()
