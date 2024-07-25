extends Node

var Camera: Camera2D
var Player: CharacterBody2D
var CurrentLevel: Node2D
var UI: CanvasLayer

var EarthWheel: Node2D
var AirWheel: Node2D
var FireWheel: Node2D
var WaterWheel: Node2D

signal switch1_entered

func _ready() -> void:
	Camera = get_node('/root/world/camera')
	Player = get_node('/root/world/character')
	EarthWheel = get_node('/root/world/ui/magic/earth')
	AirWheel = get_node('/root/world/ui/magic/air')
	FireWheel = get_node('/root/world/ui/magic/fire')
	WaterWheel = get_node('/root/world/ui/magic/water')
	CurrentLevel = get_node('/root/world/level')
	UI = get_node('/root/world/ui')
	
	Player.interact.connect(_on_player_interact)

func change_room(to: String) -> void:
	Camera.change_room(to)
	if has_signal(to + "_entered"):
		emit_signal(to + "_entered")

func _on_player_interact(collider: Node2D) -> void:
	if collider.name == "crafting":
		UI.get_node('ColorRect').visible = not UI.get_node('ColorRect').visible
	return
