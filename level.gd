class_name Level
extends Node2D

signal polygon_restraints_found

#var camera_polygon_restraints: Array[Polygon2D] = []

func _ready() -> void:
	#print(scene_file_path)
	$darkness.color = Color('#363636')
	for child in get_children():
		if child is Polygon2D:
			Global.CurrentLevel.camera_polygon_restraints[child.name] = child
			child.color.a = 0

func _process(_delta: float) -> void:
	var seconds: int = Global.time_left%60
	var minutes: int = (Global.time_left/60)%60
	var hours: int = (Global.time_left/60)/60
	
	#returns a string with the format "HH:MM:SS"
	$time_left.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
