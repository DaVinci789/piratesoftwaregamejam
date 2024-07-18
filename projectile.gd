extends CharacterBody2D

func _process(delta: float) -> void:
	velocity = transform.x * 2000
	move_and_collide(velocity * delta)
