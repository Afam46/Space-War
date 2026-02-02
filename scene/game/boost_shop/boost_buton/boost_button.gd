extends Button

@export var press_scale := 0.9
@export var press_duration := 0.1
@export var release_duration := 0.15

var boost_id: String
var tween: Tween
var screen_size

func _ready():
	screen_size = get_viewport_rect().size
	custom_minimum_size = Vector2(screen_size.x / 3.5, screen_size.y / 4.5)
	focus_mode = Control.FOCUS_NONE
	modulate = Color(1, 1, 1)
	scale = Vector2.ONE
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

func setup_boost(boost_data: Dictionary, unlocked: bool):
	$Frame.texture = load("res://aaasets/frame/frame1.png")
	
	$VBoxContainer/BoostName.text = "Locked"
	
	if $VBoxContainer/BoostPrice:
		if unlocked:
			if boost_data.get("type") == "boss":
				$VBoxContainer/BoostPrice.text = "Unlocked"
			else:
				$VBoxContainer/BoostPrice.text = "КУПЛЕНО"
				
			$VBoxContainer/BoostName.text = boost_data["name"]
					
			disabled = true
			if $Frame:
				$Frame.modulate = Color.SEA_GREEN
			var texture = load(boost_data["icon_path"])
			if texture:
				$Frame/CenterContainer/BoostIcon.texture = texture
		else:
			if boost_data.get("type") == "boss":
				$VBoxContainer/BoostPrice.text = "boss"
			else:
				$VBoxContainer/BoostPrice.text = str(boost_data["price"]) + " монет"

func _on_button_down():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(press_scale, press_scale), press_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_button_up():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, release_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _center_pivot():
	pivot_offset = size * 0.5
