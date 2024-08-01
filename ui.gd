extends CanvasLayer

var cursor_state: int = Spell_Cost.CursorState.None

func _ready() -> void:
	Global.switch0_entered.connect(_on_switch0_entered)
	$magic.modulate.a = 0
	randomize_fire()
	randomize_spell()
	randomize_rest()

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

func randomize_fire() -> void:
	var cost := Global.get_random_cost(Global.fire_cost_progression[Global.fire_gain_current])
	for i in range(4):
		%cost_fire.get_child(i).modulate = Color.TRANSPARENT
	for i in cost.length():
		%cost_fire.get_child(i).texture.region = Rect2(23 * ((int(cost[i]) - 1)), 0, 23, 22)
		%cost_fire.get_child(i).modulate = Color.WHITE
		%cost_fire.get_child(i).get_child(i).visible = true
	
func randomize_spell() -> void:
	var spell_cost := Global.get_random_spell_cost()
	var cost := spell_cost.cost
	
	%reward_spell.text = spell_cost.readable_name
	
	for i in range(4):
		%cost_spell.get_child(i).modulate = Color.TRANSPARENT
	for i in cost.length():
		%cost_spell.get_child(i).texture.region = Rect2(23 * ((int(cost[i]) - 1)), 0, 23, 22)
		%cost_spell.get_child(i).modulate = Color.WHITE
		%cost_spell.get_child(i).get_child(int(spell_cost.cost[i]) - 1).visible = true
	
	var time_gain: String = Global.time_gain_progression[Global.fire_gain_current]
	var hearts_gain: int = Global.hearts_gain_progression[Global.fire_gain_current]
	
	%fire_time_gain.text = time_gain
	
	match hearts_gain:
		0:
			%the_and_label.modulate = Color.TRANSPARENT
			%heart0.visible = false
			%heart1.visible = false
			%heart2.visible = false
		1:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = false
			%heart2.visible = false
		2:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = true
			%heart2.visible = false
		3:
			%the_and_label.modulate = Color.WHITE
			%heart0.visible = true
			%heart1.visible = true
			%heart2.visible = true
	
func randomize_rest() -> void:
	var time_spend: String = Global.time_spend_progression[Global.time_spend_current]
	%cost_rest.text = time_spend
	pass
