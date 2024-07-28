extends CanvasLayer

func _ready() -> void:
	Global.switch0_entered.connect(_on_switch0_entered)
	$magic.modulate.a = 0

func _on_switch0_entered() -> void:
	create_tween().tween_property($magic, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	$recticle.global_position = $recticle.get_global_mouse_position()
	$debug_current_room.text = "HP: " + str(Global.Player.hp)
	if $Label.text == "331":
		if (Global.EarthWheel.elements_left > 0 and Global.FireWheel.elements_left > 0) or \
		   (Global.EarthWheel.current_value > 0 and Global.FireWheel.current_value > 1):
			$Label.text = "Fireball!"
			Global.EarthWheel.current_value -= 1
			Global.FireWheel.current_value -= 2
		else:
			$Label.text = "Not enough!"
	if $Label.text == "111":
		if (Global.EarthWheel.elements_left > 0) or \
		   (Global.EarthWheel.current_value > 2):
			$Label.text = "Earthshock!"
			Global.EarthWheel.current_value -= 3
		else:
			$Label.text = "Not enough!"
