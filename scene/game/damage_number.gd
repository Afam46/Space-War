extends Node2D

@onready var label = $Label

func setup(damage: int, spawn_position: Vector2):
	global_position = spawn_position
	label.text = str(damage)
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Движение вверх
	tween.tween_property(self, "position", 
		spawn_position + Vector2(randf_range(-20, 20), -50), 0.8)
	
	# Увеличение масштаба
	tween.tween_property(self, "scale",
		Vector2(1.2, 1.2), 0.3).from(Vector2(0.5, 0.5))
	
	# Исчезновение
	tween.tween_property(self, "modulate",
		Color(1, 1, 1, 0), 0.8).set_delay(0.2)
	
	await tween.finished
	queue_free()
