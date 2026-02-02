extends CanvasLayer

@onready var animation_player = $AnimationPlayer
var is_blue_vignette_active = false
var blue_vignette_timer: Timer
var hp_local
var current_blue_intensity = 0.2
var current_blue_opacity = 0.2
var skin = GameData.skins[GameData.current_skin]

@onready var ice_overlays = [
	$IceOverlayTL,
	$IceOverlayTR,
	$IceOverlayDL,
	$IceOverlayDR
]

func _ready():
	blue_vignette_timer = Timer.new()
	blue_vignette_timer.one_shot = true
	blue_vignette_timer.timeout.connect(_on_blue_vignette_timeout)
	add_child(blue_vignette_timer)
	normal_hp()

func low_hp():
	animation_player.stop()
	$ColorRect.material.set_shader_parameter("vignette_intensity", 0.8)
	$ColorRect.material.set_shader_parameter("vignette_opacity", 0.8)
	$ColorRect.material.set_shader_parameter("vignette_rgb", Color(1.0, 0.0, 0.0, 1.0))

func hit_animation(hp, freeze_stage):
	hp_local = hp
	if freeze_stage != null and freeze_stage > 0:
		is_blue_vignette_active = true
		
		if freeze_stage == skin.max_freeze_stage:
			for ice in ice_overlays:
				ice.visible = true
				ice.modulate.a = 0.0


			var freeze_tween = create_tween()
			freeze_tween.set_parallel(true)

			for ice in ice_overlays:
				freeze_tween.tween_property(ice, "modulate:a", 1.0, 0.5)

			is_blue_vignette_active = true
			if $FreezeSound:
				$FreezeSound.pitch_scale = randf_range(0.95, 1.05)
				$FreezeSound.play()
		
		var settings
		
		if skin.max_freeze_stage == 3:
			settings = {
				1: {"intensity": 0.4, "opacity": 0.4, "duration": 3.0},
				2: {"intensity": 0.7, "opacity": 0.7, "duration": 5.0},
				3: {"intensity": 1, "opacity": 1, "duration": 3.0}
			}
		elif skin.max_freeze_stage == 6:
			settings = {
				1: {"intensity": 0.4, "opacity": 0.4, "duration": 3.0},
				2: {"intensity": 0.5, "opacity": 0.5, "duration": 5.0},
				3: {"intensity": 0.6, "opacity": 0.6, "duration": 7.0},
				4: {"intensity": 0.7, "opacity": 0.7, "duration": 9.0},
				5: {"intensity": 0.8, "opacity": 0.8, "duration": 11.0},
				6: {"intensity": 1, "opacity": 1, "duration": 3.0}
			}
		else:
			settings = {
				1: {"intensity": 0.2, "opacity": 0.2, "duration": 3.0},
				2: {"intensity": 0.3, "opacity": 0.3, "duration": 5.0},
				3: {"intensity": 0.4, "opacity": 0.4, "duration": 7.0},
				4: {"intensity": 0.5, "opacity": 0.5, "duration": 9.0},
				5: {"intensity": 0.6, "opacity": 0.6, "duration": 11.0},
				6: {"intensity": 0.7, "opacity": 0.7, "duration": 13.0},
				7: {"intensity": 0.8, "opacity": 0.8, "duration": 15.0},
				8: {"intensity": 0.9, "opacity": 0.9, "duration": 17.0},
				9: {"intensity": 1, "opacity": 1, "duration": 3.0}
			}
		
		if freeze_stage in settings:
			var config = settings[freeze_stage]
			animation_player.stop()
			
			var fade_in_tween = create_tween()
			fade_in_tween.set_parallel(true)
			
			fade_in_tween.tween_property($ColorRect.material, "shader_parameter/vignette_rgb", Color(0.331, 0.487, 1.0, 1.0), 0.5)
			
			fade_in_tween.tween_property($ColorRect.material, "shader_parameter/vignette_intensity", config.intensity, 0.5)
			fade_in_tween.tween_property($ColorRect.material, "shader_parameter/vignette_opacity", config.opacity, 0.5)
			
			current_blue_intensity = config.intensity
			current_blue_opacity = config.opacity
			
			blue_vignette_timer.stop()
			blue_vignette_timer.start(config.duration)
	else:
		animation_player.play("hit")
		await animation_player.animation_finished
		
		if not is_blue_vignette_active:
			if hp < GameData.max_hp * 0.2:
				low_hp()
			else:
				animation_player.play("RESET")

func _on_blue_vignette_timeout():
	var fade_out_tween = create_tween()
	fade_out_tween.set_parallel(true)
	
	if hp_local < GameData.max_hp * 0.3:
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_intensity", 0.8, 0.5)
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_opacity", 0.8, 0.5)
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_rgb", Color(1.0, 0.0, 0.0, 1.0), 0.5)
	else:
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_intensity", 0.3, 0.5)
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_opacity", 0.3, 0.5)
		fade_out_tween.tween_property($ColorRect.material, "shader_parameter/vignette_rgb", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	
	await fade_out_tween.finished
	
	current_blue_intensity = 0.2
	current_blue_opacity = 0.2
	
	for ice in ice_overlays:
		ice.visible = false
		
	is_blue_vignette_active = false

func check_hp(hp):
	if not is_blue_vignette_active and hp >= GameData.max_hp * 0.2:
		normal_hp()
		
func normal_hp():
	animation_player.stop()
	
	var fade_tween = create_tween()
	fade_tween.set_parallel(true)
	
	fade_tween.tween_property($ColorRect.material, "shader_parameter/vignette_intensity", 0.3, 0.5)
	fade_tween.tween_property($ColorRect.material, "shader_parameter/vignette_opacity", 0.3, 0.5)
	fade_tween.tween_property($ColorRect.material, "shader_parameter/vignette_rgb", Color(1.0, 1.0, 1.0, 1.0), 0.5)
	
	await fade_tween.finished
	animation_player.play("RESET")
	current_blue_intensity = 0.2
	current_blue_opacity = 0.2
	
	for ice in ice_overlays:
		ice.visible = false
		
	is_blue_vignette_active = false
