class_name Level
extends Node2D

signal polygon_restraints_found

#var camera_polygon_restraints: Array[Polygon2D] = []

func _ready() -> void:
	#print(scene_file_path)
	for child in get_children():
		if child is Polygon2D:
			#camera_polygon_restraints.append(child)
			Global.CurrentLevel.camera_polygon_restraints[child.name] = child
	# emit_signal("polygon_restraints_found")
