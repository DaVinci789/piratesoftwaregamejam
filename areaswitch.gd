extends ColorRect

@export var scene_to := ""

func _ready() -> void:
	$areaswitch/CollisionShape2D.shape.size = size
	visible = false

func _on_body_entered(_body: Node2D) -> void:
	Global.change_room(scene_to)
	set_deferred("monitoring", false)
	pass # Replace with function body.
