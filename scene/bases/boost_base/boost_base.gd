extends Area2D

var speed = 0

@export var particle_scene: PackedScene

func _physics_process(delta):
	position += Vector2.DOWN * speed * delta

func _on_area_entered(area):
	if area.is_in_group("player"):
		collect(area)

func use_boost(_player):
	pass

func collect(player):
	use_boost(player)
	
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
	
	if particle_scene:
		var particles = particle_scene.instantiate()
		particles.global_position = global_position
		get_parent().add_child(particles)
		particles.emitting = true
		particles.one_shot = true
