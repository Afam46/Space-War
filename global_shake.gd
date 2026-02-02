extends Node

var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta
		
		var offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		) * (shake_timer / shake_duration)

		# Применяем тряску ко ВСЕМ CanvasLayer в сцене
		apply_shake_to_all_canvas_layers(offset)
	else:
		# Сбрасываем тряску
		apply_shake_to_all_canvas_layers(Vector2.ZERO)

func apply_shake_to_all_canvas_layers(offset: Vector2):
	var root = get_tree().current_scene
	if root:
		var layers = root.find_children("*", "CanvasLayer", true, false)
		for layer in layers:
			var margin_container = layer.get_node_or_null("MarginContainer")
			if margin_container:
				margin_container.position = offset

func start_shake(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration
