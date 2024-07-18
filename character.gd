extends CharacterBody2D

@export var SPEED := 700
@export var DASH_DURATION_SECONDS := 0.2
@export var DASH_LENGTH := 350
@export var ELEMENT_INPUT_TIMEOUT := 0.5 :
	set(value):
		$element_input_timeout.wait_time = value

@export var element_input_label: Label
@onready var projectile_scene := preload("res://projectile.tscn")

enum STATES {
	Normal,
	Dash,
	Dash_Enter,
	Dash_Exit,
}

var state := STATES.Normal

var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO

func _ready() -> void:
	$element_input_timeout.wait_time = ELEMENT_INPUT_TIMEOUT

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
	match state:
		STATES.Normal:
			get_input()
			$Sprite2D2.position = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized() * DASH_LENGTH
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
				
			move_and_collide(velocity * delta)
			pass
		STATES.Dash_Enter:
			var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
			dashing_target = position + direction * DASH_LENGTH
			
			var tween := create_tween()
			current_target = position
			tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			tween.finished.connect(_on_dash_timeout)
			state = STATES.Dash
			pass
		STATES.Dash:
			velocity = (current_target - position).normalized() * (DASH_LENGTH / DASH_DURATION_SECONDS) 
			move_and_collide(velocity * delta)
			pass
		STATES.Dash_Exit:
			dashing_target = Vector2.ZERO
			state = STATES.Normal
			pass

func special_activated() -> Array:
	var mouse_special := Input.is_action_just_pressed("special")
	var joystick_special := Input.get_vector("special_left", "special_right", "special_up", "special_down")
	return [mouse_special || joystick_special != Vector2.ZERO, joystick_special]

func _on_dash_timeout() -> void:
	state = STATES.Dash_Exit
	pass # Replace with function body.
