extends Sprite2D

var speed = 200
var angular_speed = PI
@export var smoke_particles: PackedScene

func _ready():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)

func _process(delta):
	position += Vector2.UP * speed * delta
	rotation += angular_speed * delta


func _on_spawn_smoke_timeout():
	set_process(false)
	var smoke = smoke_particles.instantiate()
	smoke.position = position
	add_child(smoke)
	await get_tree().create_timer(3).timeout
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	await get_tree().create_timer(13).timeout
	queue_free()

func _on_area_2d_body_entered(body):
	if randf() * 100 <= 50:
		if body and body.is_in_group("bullets"):
			await get_tree().create_timer(0.3).timeout
			if is_instance_valid(body):
				body.queue_free()

func speed_up():
	speed = -200
	set_process(true)
