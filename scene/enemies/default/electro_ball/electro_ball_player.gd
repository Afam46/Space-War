extends RigidBody2D

var speed = 200
var damage = 5000
var boss12
var direction = Vector2.UP

func _ready():
	$AnimatedSprite2D.animation = "fly"
	$AnimatedSprite2D.play()
	boss12 = get_tree().get_first_node_in_group("boss12")

func _physics_process(delta):
	if boss12 and is_instance_valid(boss12):
		direction = (boss12.global_position - global_position).normalized()
		
	var collision = move_and_collide(direction * delta * speed)
	if collision:
		var collider = collision.get_collider()
		if collider and collider.has_method("destroy"):
			collider.destroy(damage)
		queue_free()

func _on_timer_timeout():
	queue_free()
