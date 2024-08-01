extends Node2D

var camera_polygon_restraints := {} # [String => Polygon2D]

func _on_camp_exit_body_entered(body: Node2D) -> void:
	Global.Player.global_position = $dungeon_entrance.global_position
	Global.Camera.global_position = $dungeon_camera_snap.global_position
	Global.Camera.polygon_restraint = camera_polygon_restraints["dungeon_entrance"]
	Global.audios["camp"].stop()
	Global.audios["outlands"].play()
	Global.Player.get_node("PointLight2D").visible = true
	%tutcamp0.visible = false
	%tutcamp1.visible = true
	pass # Replace with function body.

func _on_dungeon_exit_body_entered(body: Node2D) -> void:
	Global.Player.global_position = $camp_entrance.global_position
	Global.Camera.global_position = $camp_camera_snap.global_position
	Global.Camera.polygon_restraint = camera_polygon_restraints["camp_restraint"]
	Global.audios["camp"].play()
	Global.audios["outlands"].stop()
	Global.Player.get_node("PointLight2D").visible = false
	pass # Replace with function body.

func _ready() -> void:
	Global.camp_entrance = $camp_entrance
	Global.camp_camera_snap = $camp_camera_snap


func _on_exit_tutorial_body_entered(body: Node2D) -> void:
	Global.Player.global_position = $awaken_entrance.global_position
	Global.Camera.global_position = $camp_camera_snap.global_position
	Global.Camera.polygon_restraint = camera_polygon_restraints["camp_restraint"]
	Global.audios["camp"].play()
	$outlands.darkness_visible()
	
	Global.UI.get_node("magic").get_node("earth").elements_left = 1
	Global.UI.get_node("magic").get_node("earth").current_value = 6
	Global.UI.get_node("magic").get_node("air").elements_left = 1
	Global.UI.get_node("magic").get_node("air").current_value = 6
	Global.UI.get_node("magic").get_node("fire").elements_left = 1
	Global.UI.get_node("magic").get_node("fire").current_value = 6
	Global.UI.get_node("magic").get_node("water").elements_left = 1
	Global.UI.get_node("magic").get_node("water").current_value = 6
	pass # Replace with function body.
