extends Area2D

var speed = 100
@export var particle_scene: PackedScene
var is_collected = false

@onready var icon_sprite = $IconSprite

func collect(player):
	if is_collected:
		return
	
	is_collected = true
	
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
	
	apply_boost(player)

	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
	
	if particle_scene:
		var particles = particle_scene.instantiate()
		particles.global_position = global_position
		get_parent().add_child(particles)
		particles.emitting = true
		particles.one_shot = true
		await get_tree().create_timer(particles.lifetime).timeout
		particles.queue_free()

func apply_boost(_player):
	pass

func _physics_process(delta):
	position += Vector2.DOWN * delta * speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func speed_up():
	speed = 400
	await get_tree().create_timer(2).timeout
	speed = 100
	
func full_speed_up():
	speed = 1000
