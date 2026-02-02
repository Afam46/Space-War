extends "res://scene/bases/enemy_base/enemy_base.gd"

var rand_angular_speed

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
]

func _ready():
	randomize()
	max_freeze_stage = 1
	coin_chance = 35
	speed = 300
	speed_after_death = 200
	rand_angular_speed = randf_range(PI/8, PI)
	angular_speed = rand_angular_speed
	angular_speed_after_death = rand_angular_speed

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)
	rotation += angular_speed * delta

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = meteor_sounds[randi() % meteor_sounds.size()]
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()

	# Удалить звук после окончания
	sfx.connect("finished", sfx.queue_free)


func instant_death():
	super.die()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func destroy(player_damage):
	plyr_damage = player_damage
	hp -= plyr_damage

	if particle_scene:
		call_deferred("show_particles")
	
	if freeze_stage == 0:
		call_deferred("hit_anim")
		
	if hp <= 0:
		die()
