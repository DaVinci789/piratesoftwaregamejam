extends Node2D

var camera_polygon_restraints: Array[Polygon2D] = []:
	get:
		var result: Array[Polygon2D] = []
		for child: Level in get_children():
			for polygon: Polygon2D in child.camera_polygon_restraints:
				result.append(polygon)
		return result
