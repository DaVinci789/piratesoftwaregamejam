extends CanvasLayer

var cursor_state: int = Spell_Cost.CursorState.None

func _ready() -> void:
	Global.switch0_entered.connect(_on_switch0_entered)
	$magic.modulate.a = 0

func _on_switch0_entered() -> void:
	create_tween().tween_property($magic, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)

func _process(_delta: float) -> void:
	$recticle.global_position = $recticle.get_global_mouse_position()
	$fist.global_position = $fist.get_global_mouse_position()
	match cursor_state:
		Spell_Cost.CursorState.None:
			$recticle.visible = false
			$fist.visible = false
			pass
		Spell_Cost.CursorState.Target:
			$recticle.visible = true
			pass
		Spell_Cost.CursorState.Special:
			$fist.visible = true
			pass
	$debug_current_room.text = "HP: " + str(Global.Player.hp)
	
func load_spell(spell: Spell_Cost) -> bool:
	var the_slot: Node2D = null
	for node: Node2D in [$magic/Spellslots1, $magic/Spellslots2, $magic/Spellslots3]:
		if node.get_node("nametag/Label").text == "":
			the_slot = node
			break
	if the_slot:
		the_slot.get_node("nametag").visible = true
		the_slot.get_node("nametag/Label").text = spell.readable_name
		for i in range(spell.cost.length()):
			var ch := spell.cost[i]
			the_slot.get_node("slot" + str(i + 1)).get_node(ch).visible = true
			the_slot.get_node("slot" + str(i + 1) + "/keys/1").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/2").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/3").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/4").visible = false
			the_slot.get_node("slot" + str(i + 1) + "/keys/" + ch).visible = true
	return the_slot != null
	pass

func light_element_input(input: String) -> void:
	# List of nodes to check
	var nodes := [$magic/Spellslots1, $magic/Spellslots2, $magic/Spellslots3]
	
	# Iterate through each node
	for node: Node2D in nodes:
		var cumulative_match := true  # Start with cumulative match set to true

		# Iterate through each character in the input string
		for i in range(input.length()):
			var symbol_path := "slot" + str(i + 1) + "/keys/" + input[i]
			var symbol: Label = node.get_node(symbol_path)

			# If cumulative match is still true and the symbol is visible
			if cumulative_match and symbol.visible:
				symbol.material.set("shader_parameter/enable", true)
			else:
				node.get_node("slot" + str(i + 1) + "/keys/1").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/2").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/3").material.set("shader_parameter/enable", false)
				node.get_node("slot" + str(i + 1) + "/keys/4").material.set("shader_parameter/enable", false)
				cumulative_match = false  # Set to false if the match breaks
	return

func reset_cast_indicator() -> void:
	cursor_state = Spell_Cost.CursorState.None
	var nodes := [
		get_node("magic/Spellslots1/slot1/keys"),
		get_node("magic/Spellslots1/slot2/keys"),
		get_node("magic/Spellslots1/slot3/keys"),
		get_node("magic/Spellslots1/slot4/keys"),
		get_node("magic/Spellslots2/slot1/keys"),
		get_node("magic/Spellslots2/slot2/keys"),
		get_node("magic/Spellslots2/slot3/keys"),
		get_node("magic/Spellslots2/slot4/keys"),
		get_node("magic/Spellslots3/slot1/keys"),
		get_node("magic/Spellslots3/slot2/keys"),
		get_node("magic/Spellslots3/slot3/keys"),
		get_node("magic/Spellslots3/slot4/keys"),
	]
	
	for node: Node2D in nodes:
		var children: Array = node.get_children()
		for child: Label in children:
			child.material.set_shader_parameter("enable", false)
	pass
