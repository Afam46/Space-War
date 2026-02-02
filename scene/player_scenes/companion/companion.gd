extends Area2D

var hp = 50
var orbit_radius = 100.0
var orbit_speed = 1
var angle = 0.0
var player: Node2D

@export var bullet_scene: PackedScene
@export var damage_number_scene: PackedScene

var shot_index = 0

func _ready():
	$AnimatedSprite2D.play()
	find_player()

func find_player():
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		var scene_root = get_tree().current_scene
		if scene_root.has_node("Player"):
			player = scene_root.get_node("Player")
	
	if not player:
		var parent = get_parent()
		if parent:
			for child in parent.get_children():
				if "player" in child.name.to_lower() or child.is_in_group("player"):
					player = child
					break

func _process(delta):
	angle += orbit_speed * delta
	var offset = Vector2(cos(angle), sin(angle)) * orbit_radius
	global_position = player.global_position + offset

func _on_shot_timeout():
	shot()

func shot():
	$ShotSound.play()
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(0, -50)
	get_parent().add_child(bullet)

func _on_body_entered(body):
	if body:
		if body.has_method("destroy"):
			body.destroy(5)
			hit(body.damage)

func hit(damage):
	$Hit.play()
	hp -= damage
	hit_anim(damage)
	if hp <= 0:
		die()

func hit_anim(damage):
	show_damage_number(damage)

	$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	$AnimatedSprite2D.modulate = Color.WHITE

func show_damage_number(damage: int):
	if damage_number_scene:
		var damage_number = damage_number_scene.instantiate()
		
		# Позиция над игроком
		var spawn_position = global_position + Vector2(randf_range(-10, 10), -60)
		
		get_parent().get_parent().add_child(damage_number)
		damage_number.setup(damage, spawn_position)

func die():
	orbit_speed = 0
	$AnimatedSprite2D.animation = "death"
	
	if $AnimatedSprite2D.sprite_frames:
		$AnimatedSprite2D.sprite_frames.set_animation_loop("death", false)
		
	$AnimatedSprite2D.play()
	
	$Death.play()

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)
		
	$Shot.stop()
	
	await $AnimatedSprite2D.animation_finished
	
	queue_free()
