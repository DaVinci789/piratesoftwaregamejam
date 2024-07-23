extends Node

var Camera: Camera2D
var Player: CharacterBody2D

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

func change_room(to: String) -> void:
	Camera.change_room(to)
	if has_signal(to + "_entered"):
		emit_signal(to + "_entered")
