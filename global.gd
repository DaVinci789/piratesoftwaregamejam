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

signal switch0_entered

func _ready() -> void:
	var min_size := Vector2.ZERO
	min_size.x = ProjectSettings.get_setting('display/window/size/viewport_width')
	min_size.y = ProjectSettings.get_setting('display/window/size/viewport_height')
	get_window().min_size = min_size
	
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

func change_room(to: String) -> void:
	for enemy: Node2D in CurrentLevel.camera_polygon_restraints[Camera.polygon_restraint_target].get_children():
		enemy.ACTIVE = false
	Camera.change_room(to)
	for enemy: Node2D in CurrentLevel.camera_polygon_restraints[to].get_children():
		enemy.ACTIVE = true
		enemy.action_state = Enemy.ACTION_STATES.Chase
	# var enemies := CurentLevel.enemies()
	# for enemy: Node2D in enemies:
	#    enemy.active = false
	if has_signal(to + "_entered"):
		emit_signal(to + "_entered")

func effect_player(effect: Effect) -> void:
	Player.hp -= effect.damage

func _on_player_interact(collider: Node2D) -> void:
	if collider.name == "crafting":
		UI.get_node('ColorRect').visible = not UI.get_node('ColorRect').visible
	return
