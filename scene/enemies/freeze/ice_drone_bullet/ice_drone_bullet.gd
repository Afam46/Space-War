extends RigidBody2D

var speed = 1000
var damage = randi_range(1, 5)
var freeze_power = 2
var direction = Vector2.DOWN
var is_player_bullet = false
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
		queue_free()
	
func instant_death():
	queue_free()
	
func destroy(_damage):
	queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func make_player_bullet():
	if rico_count >= 5:
		queue_free()
	rico_count += 1
	play_ricochet_sound()
	is_player_bullet = true
	set_collision_layer_value(1, false)
	set_collision_mask_value(2, true)
	update_direction()
	$Sprite2D.rotation = 0

func make_enemy_bullet():
	if rico_count >= 5:
		queue_free()
	rico_count += 1
	play_ricochet_sound()
	is_player_bullet = false
	set_collision_layer_value(1, true)
	set_collision_mask_value(2, false)
	update_direction()
	$Sprite2D.rotation = PI

func play_ricochet_sound():
	var sfx = ricochet_sounds[randi() % ricochet_sounds.size()]
	$RicochetSound.stream = sfx
	$RicochetSound.pitch_scale = randf_range(0.95, 1.05)
	$RicochetSound.play()

func update_direction():
	if is_player_bullet:
		direction = Vector2.UP.rotated(rotation)
	else:
		direction = Vector2.DOWN.rotated(-rotation)
