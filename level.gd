class_name Level
extends Node2D

signal polygon_restraints_found

var camera_polygon_restraints: Array[Polygon2D] = []

func _ready() -> void:
	for child in get_children():
		if child is Polygon2D:
			camera_polygon_restraints.append(child)
	emit_signal("polygon_restraints_found")
