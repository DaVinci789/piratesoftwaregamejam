extends Node

var Camera: Camera2D
var Player: CharacterBody2D
var Projectiles: Node
var CurrentLevel: Node2D
var UI: CanvasLayer

var EarthWheel: Node2D
var AirWheel: Node2D
var FireWheel: Node2D
var WaterWheel: Node2D

var spells_name := {}
var spells_cost := {}
var spell_path := "res://spells/"
var spell_dir: DirAccess = null

var time_left := 0
var times_increased_time := 0

signal switch0_entered


func _ready() -> void:
	var min_size := Vector2.ZERO
	min_size.x = ProjectSettings.get_setting('display/window/size/viewport_width')
	min_size.y = ProjectSettings.get_setting('display/window/size/viewport_height')
	get_window().min_size = min_size
	
	spell_dir = DirAccess.open(spell_path)
	spell_dir.list_dir_begin()
	var file_name := spell_dir.get_next()
	while file_name != "":
		if ".tres" in file_name:
			var spell_cost := ResourceLoader.load(spell_path + file_name)
			if not spells_cost.has(spell_cost.cost):
				spells_cost[spell_cost.cost] = []
			spells_cost[spell_cost.cost].append([spell_cost, load(spell_path + file_name.get_file().get_basename() + ".tscn")])
			print(file_name)
			spells_name[spell_cost.readable_name.to_lower().replace(" ", "_")] = ([spell_cost, load(spell_path + file_name.get_file().get_basename() + ".tscn")])
		file_name = spell_dir.get_next()
	
	Camera = get_node('/root/world/camera')
	Player = get_node('/root/world/character')
	Projectiles = get_node('/root/world/projectiles')
	EarthWheel = get_node('/root/world/ui/magic/earth')
	AirWheel = get_node('/root/world/ui/magic/air')
	FireWheel = get_node('/root/world/ui/magic/fire')
	WaterWheel = get_node('/root/world/ui/magic/water')
	CurrentLevel = get_node('/root/world/level')
	UI = get_node('/root/world/ui')
	
	if Player:
		Player.interact.connect(_on_player_interact)

func _process(_delta: float) -> void:
	if not CurrentLevel:
		return
	time_left = floor(CurrentLevel.get_node("time_left").time_left)

func change_room(to: String, enable_enemies_in: String, disable_enemies_in: String) -> void:
	for enemy: Node2D in CurrentLevel.camera_polygon_restraints[Camera.polygon_restraint_target].get_children():
		enemy.ACTIVE = false
	Camera.change_room(to)
	if enable_enemies_in != "":
		for enemy: Node2D in CurrentLevel.camera_polygon_restraints[enable_enemies_in].get_children():
			enemy.ACTIVE = true
			enemy.action_state = Enemy.ACTION_STATES.Chase
		Global.CurrentLevel.find_child("outlands").get_node("darkness").color = Color("#080808")
			
	if disable_enemies_in != "":
		for enemy: Node2D in CurrentLevel.camera_polygon_restraints[disable_enemies_in].get_children():
			enemy.ACTIVE = false
			enemy.action_state = Enemy.ACTION_STATES.Idle
		Global.CurrentLevel.find_child("outlands").get_node("darkness").color = Color("#363636")
	if has_signal(to + "_entered"):
		emit_signal(to + "_entered")


func get_random_spell() -> PackedScene:
	var keys := spells_cost.keys()
	keys.shuffle()
	var spells: Array = spells_cost[keys[0]]
	spells.shuffle()
	return spells[0][1]
	pass

func get_random_timer_increase(length: int) -> String:
	var output := ""
	var choices := ["1","2","3","4",]
	for i in range(length):
		choices.shuffle()
		output += choices[0]
	return output

func _on_player_interact(collider: Node2D) -> void:
	if collider.name == "crafting":
		UI.get_node('ColorRect').visible = not UI.get_node('ColorRect').visible
	return
