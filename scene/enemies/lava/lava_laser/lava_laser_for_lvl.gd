extends "res://scene/bases/enemy_base/enemy_base.gd"

@onready var meteor_sounds = [
	preload("res://aasounds/meteor_destroy_1.wav"),
	preload("res://aasounds/meteor_destroy_2.wav"),
	preload("res://aasounds/meteor_destroy_3.wav")
]

func _ready():
	randomize()
	hp = 1000
	speed = 300
	speed_after_death = 200
	damage = 30
	boost_chance = 0
	$VisibleOnScreenNotifier2D.set_process(false)
	$VisibleOnScreenNotifier2D.set_physics_process(false)

func _physics_process(delta):
	move_and_collide(Vector2.DOWN * speed * delta)

func play_death_sound():
	var sfx = AudioStreamPlayer.new()
	sfx.stream = meteor_sounds[randi() % meteor_sounds.size()]
	sfx.volume_db = -8
	get_tree().current_scene.add_child(sfx)
	sfx.play()
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

func _on_visible_on_screen_notifier_2d2_screen_entered():
	$VisibleOnScreenNotifier2D.set_process(true)
	$VisibleOnScreenNotifier2D.set_physics_process(true)
