extends AnimatedSprite2D

var speed = 200
var angular_speed = PI
@export var sharp_scene: PackedScene
@export var spark_grenade_scene: PackedScene 

@onready var death_sounds_small = [
	preload("res://aasounds/explosion_small_1.wav"),
	preload("res://aasounds/explosion_small_2.wav"),
	preload("res://aasounds/explosion_small_3.wav"),
]

func _process(delta):
	position += Vector2.UP * speed * delta
	rotation += angular_speed * delta

func _on_life_time_timeout():
	play_death_sound()
	animation = "death"
	sprite_frames.set_animation_loop("death", false)
	play()
	speed = 0
	angular_speed = 0
	show_particles()
	sharps_spawn()
	await animation_finished
	queue_free()

func sharps_spawn():
	for i in range(12):
		var sharp = sharp_scene.instantiate()
		sharp.global_position = global_position
		get_parent().add_child(sharp)

func speed_up():
	speed = -200

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = death_sounds_small[randi() % death_sounds_small.size()]
	sfx.volume_db = 20
	get_tree().current_scene.add_child(sfx)
	sfx.play()

	sfx.connect("finished", sfx.queue_free)

func show_particles():
	var particles = spark_grenade_scene.instantiate()
	particles.global_position = global_position
	get_parent().add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	await get_tree().create_timer(2).timeout
	particles.queue_free()
