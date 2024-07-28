@tool
extends ColorRect

@export_category("Current Scene")
@export_file("*.tscn") var this_level := ""
@export var snap_camera_to_polygon := ""
@export var snap_camera_to_polygon_swap := ""

@export_category("Next Scene")
@export_file("*.tscn") var connect_to_scene := ""
@export var next_area_load_radius := 50
@export var next_area_load_visible := false
@export var load_next_scene_at: Marker2D = null


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	%cameraswitch/CollisionShape2D.shape.size = size
	%next_area_load/CollisionShape2D.shape.radius = next_area_load_radius
	if connect_to_scene != "":
		ResourceLoader.load_threaded_request(connect_to_scene)
	else:
		%next_area_load.monitoring = false
	#visible = false

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	%next_area_load/CollisionShape2D.shape.radius = next_area_load_radius
	%next_area_load.position =  size / 2
	%next_area_load.visible = next_area_load_visible

func _on_cameraswitch_body_entered(_body: Node2D) -> void:
	Global.change_room(snap_camera_to_polygon)
	var temp := snap_camera_to_polygon
	snap_camera_to_polygon = snap_camera_to_polygon_swap
	snap_camera_to_polygon_swap = temp
	set_deferred("monitoring", false)
	pass # Replace with function body.


func _on_next_area_load_body_entered(_body: Node2D) -> void:
	if not load_next_scene_at:
		return
	var next_scene := ResourceLoader.load_threaded_get(connect_to_scene)
	var scene: Node2D = next_scene.instantiate()
	scene.global_position = load_next_scene_at.global_position
	Global.CurrentLevel.call_deferred("add_child", scene)
	pass # Replace with function body.
