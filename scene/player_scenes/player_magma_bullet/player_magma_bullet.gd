extends Area2D

@export var small_magma_bullet_scene: PackedScene
var speed = 500
var damage = randi_range(10, 20) + GameData.damage_bonus
var angular_speed = PI
var direction = Vector2.UP

func _ready():
	$AnimatedSprite2D.animation = "create"
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("create", false)
	$AnimatedSprite2D.play()
	
	await $AnimatedSprite2D.animation_finished
	
	$AnimatedSprite2D.animation = "fly"
	$AnimatedSprite2D.play()

func _physics_process(delta):
	position += direction * delta * speed
	rotation += angular_speed * delta

var isSplit = false

func instant_death():
	if not isSplit:
		split()
	
func destroy(_damage):
	if not isSplit:
		split()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func split():
	isSplit = true
	$CollisionShape2D.set_deferred("disabled", true)
	call_deferred("_deferred_split")

func _deferred_split():
	for i in range(2):
		var small_magma_bullet = small_magma_bullet_scene.instantiate()
		small_magma_bullet.global_position = global_position + Vector2(20 * (i+1), 0)
		get_parent().add_child(small_magma_bullet)
	for i in range(2):
		var small_magma_bullet = small_magma_bullet_scene.instantiate()
		small_magma_bullet.global_position = global_position + Vector2(20 * (-i-1), 0)
		get_parent().add_child(small_magma_bullet)
	
	queue_free()


func _on_body_entered(body):
	if body:
		if body.has_method("destroy"):
			body.destroy(damage)
	split()

func set_direction_from_player(rot):
	rotation = rot
	direction = Vector2.UP.rotated(rot)
