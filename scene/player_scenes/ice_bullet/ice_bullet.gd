extends RigidBody2D

var speed = 600
var damage = randi_range(7, 12) + GameData.damage_bonus
var direction = Vector2.UP
var is_enemy_bullet = false
var rico_count = 0

@onready var ricochet_sounds = [
	preload("res://aasounds/ricochet/ricochet_1.wav"),
	preload("res://aasounds/ricochet/ricochet_2.wav"),
	preload("res://aasounds/ricochet/ricochet_3.wav")
]

func _physics_process(delta):
	var collision = move_and_collide(direction * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider and collider.has_method("destroy"):
			collider.destroy(damage)
			if collider.has_method("freeze"):
				collider.freeze()
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy(_damage):
	queue_free()

func make_enemy_bullet():
	if rico_count >= 5:
		queue_free()
	rico_count += 1
	is_enemy_bullet = true
	play_ricochet_sound()
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, false)
	update_direction()
	if has_node("Sprite2D"):
		$Sprite2D.rotation = PI

func make_player_bullet():
	if rico_count >= 5:
		queue_free()
	rico_count += 1
	is_enemy_bullet = false
	play_ricochet_sound()
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, true)
	update_direction()
	if has_node("Sprite2D"):
		$Sprite2D.rotation = 0

func play_ricochet_sound():
	var sfx = ricochet_sounds[randi() % ricochet_sounds.size()]
	$RicochetSound.stream = sfx
	$RicochetSound.pitch_scale = randf_range(0.95, 1.05)
	$RicochetSound.play()

func update_direction():
	if is_enemy_bullet:
		set_direction_from_enemy(-rotation)
	else:
		set_direction_from_player(rotation)

func set_direction_from_enemy(rot):
	rotation = rot
	direction = Vector2.DOWN.rotated(rot)

func set_direction_from_player(rot):
	rotation = rot
	direction = Vector2.UP.rotated(rot)
