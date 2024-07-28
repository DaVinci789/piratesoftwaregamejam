extends CharacterBody2D

func _process(delta: float) -> void:
	velocity = transform.x * 2000
	var collision := move_and_collide(velocity * delta)
	if collision:
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	pass # Replace with function body.
