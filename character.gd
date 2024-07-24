extends CharacterBody2D

@export var SPEED := 700
@export var CAMERA_INPUT_UPDATE := 0.1
@export var DASH_DURATION_SECONDS := 0.2
@export var DASH_LENGTH := 350
@export var CAMERA_TRACKING_OFFSET := 200
@export var ELEMENT_INPUT_TIMEOUT := 0.5 :
	set(value):
		if $element_input_timeout:
			$element_input_timeout.wait_time = value
@export var PUSH_STRENGTH := 70

@export var element_input_label: Label

@onready var projectile_scene := preload("res://projectile.tscn")
@onready var camera_target: Vector2:
	get:
		return $cameratarget.global_position
var move_camera_target := true

enum STATES {
	Normal,
	Dash,
	Dash_Enter,
	Dash_Exit,
}

var state := STATES.Normal

var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO
var dash_previous_position := Vector2.ZERO
var dash_time_elapsed := 0.0

func _ready() -> void:
	$element_input_timeout.wait_time = ELEMENT_INPUT_TIMEOUT
	if element_input_label == null:
		element_input_label = Label.new()

func get_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * SPEED

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("element_1"):
		element_input_label.text += "1"
	if Input.is_action_just_pressed("element_2"):
		element_input_label.text += "2"
	if Input.is_action_just_pressed("element_3"):
		element_input_label.text += "3"
	if Input.is_action_just_pressed("element_4"):
		element_input_label.text += "4"
	
	if element_input_label.text.length() != 0 and $element_input_timeout.is_stopped():
		$element_input_timeout.start()
	
	match state:
		STATES.Normal:
			get_input()
			if Input.is_action_just_pressed("dash"):
				state = STATES.Dash_Enter
			
			var special_activate := special_activated()
			if element_input_label.text == "Fireball!" and special_activate[0] == true:
				element_input_label.text = ""
				var to_launch := projectile_scene.instantiate()
				to_launch.global_position = global_position
				if special_activate[1] != Vector2.ZERO:
					to_launch.rotate(special_activate[1].angle())
				else:
					to_launch.look_at(get_global_mouse_position())
				get_tree().root.add_child(to_launch)
			
			var collision := move_and_collide(velocity * delta)
			if collision:
				handle_collision(collision)
			pass
		STATES.Dash_Enter:
			var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			dashing_target = position + direction * DASH_LENGTH
			dash_previous_position = position
			dash_time_elapsed = 0.0
			
			var tween := create_tween()
			current_target = position
			tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.finished.connect(_on_dash_timeout)
			state = STATES.Dash
			pass
		STATES.Dash:
			#velocity = (current_target - position).normalized() * (DASH_LENGTH / DASH_DURATION_SECONDS) 
			#move_and_collide(velocity * delta)
			dash_time_elapsed += delta
			if dash_time_elapsed > DASH_DURATION_SECONDS:
				dash_time_elapsed = DASH_DURATION_SECONDS  # Clamp to max duration
			
			# Calculate velocity based on the change in position
			var new_position := dash_previous_position.lerp(current_target, dash_time_elapsed / DASH_DURATION_SECONDS)
			velocity = (new_position - position) / delta
			
			move_and_collide(velocity * delta)
			dash_previous_position = new_position
			pass
		STATES.Dash_Exit:
			dashing_target = Vector2.ZERO
			state = STATES.Normal
			pass

func special_activated() -> Array:
	var mouse_special := Input.is_action_just_pressed("special")
	var joystick_special := Input.get_vector("special_left", "special_right", "special_up", "special_down")
	return [mouse_special || joystick_special != Vector2.ZERO, joystick_special]

func handle_collision(collision: KinematicCollision2D) -> void:
	var collider := collision.get_collider()
	if collider:
		collider.push(-collision.get_normal().normalized() * PUSH_STRENGTH)

func _on_dash_timeout() -> void:
	state = STATES.Dash_Exit
	pass # Replace with function body.

func _on_cameratarget_update_timeout() -> void:
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Check if the input vector is not zero
	if input_vector != Vector2.ZERO:
		# Restrict movement to cardinal directions
		var cardinal_vector := Vector2.ZERO
		if abs(input_vector.x) > abs(input_vector.y):
			# Horizontal movement (left or right)
			cardinal_vector.x = sign(input_vector.x)
		else:
			# Vertical movement (up or down)
			cardinal_vector.y = sign(input_vector.y)

		# Update the camera target position
		$cameratarget.position = cardinal_vector.normalized() * CAMERA_TRACKING_OFFSET
	pass # Replace with function body.

func _on_element_input_timeout_timeout() -> void:
	if element_input_label.text != "Fireball!":
		element_input_label.text = ""
