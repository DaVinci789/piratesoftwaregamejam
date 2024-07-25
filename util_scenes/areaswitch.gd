@tool
extends ColorRect

@export_file("*.tscn") var connect_to := ""
@export var scene_to := ""
@export var next_area_load_radius := 50
@export var next_area_load_visible := false
@export var load_next_scene_at: Marker2D = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$areaswitch/CollisionShape2D.shape.size = size
	$next_area_load/CollisionShape2D.shape.radius = next_area_load_radius
	ResourceLoader.load_threaded_request(connect_to)
	visible = false

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	$next_area_load/CollisionShape2D.shape.radius = next_area_load_radius
	$next_area_load.position =  size / 2
	$next_area_load.visible = next_area_load_visible

func _on_body_entered(_body: Node2D) -> void:
	Global.change_room(scene_to)
	set_deferred("monitoring", false)
	pass # Replace with function body.


func _on_next_area_load_body_entered(_body: Node2D) -> void:
	if not load_next_scene_at:
		return
	var next_scene := ResourceLoader.load_threaded_get(connect_to)
	var scene: Node2D = next_scene.instantiate()
	scene.global_position = load_next_scene_at.global_position
	Global.CurrentLevel.call_deferred("add_child", scene)
	pass # Replace with function body.
