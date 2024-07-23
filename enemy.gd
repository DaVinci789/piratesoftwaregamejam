@tool
extends CharacterBody2D

@export_group("Behavior Testing")
@export var dash_button := false:
	set(value):
		dash()

@export_group("Parameters")
@export var BASE_SPEED := 600
@export var DASH_LENGTH := 350
@export var DASH_DURATION_SECONDS := 0.2
@export var KEEP_DISTANCE_FROM_PLAYER := 500

signal dash_finished

enum ACTION_STATES {
	Idle,
	Chase,
	Dash_Catchup,
	Dash_Attack_Enter,
	Dash_Attack,
}

var action_state := ACTION_STATES.Idle

var is_dashing := false
var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	print(ACTION_STATES.keys()[action_state])
	
	if is_dashing:
		update_dash(delta)
	
	match action_state:
		ACTION_STATES.Idle:
			var to_player := position.direction_to(Global.Player.position)
			move_and_collide(to_player * BASE_SPEED * delta)
			
			if position.distance_to(Global.Player.position) < KEEP_DISTANCE_FROM_PLAYER:
				action_state = ACTION_STATES.Dash_Attack_Enter
			pass
		ACTION_STATES.Chase:
			pass
		ACTION_STATES.Dash_Attack_Enter:
			dash_attack()
			action_state = ACTION_STATES.Dash_Attack
		ACTION_STATES.Dash_Attack:
			pass

func dash_attack() -> void:
	dash()
	await dash_finished
	action_state = ACTION_STATES.Idle
	pass

func dash() -> void:
	if not is_dashing:
		start_dash()
	pass

func start_dash() -> void:
	is_dashing = true
	
	dashing_target = position + position.direction_to(Global.Player.position) * DASH_LENGTH
	current_target = position
	
	var tween := create_tween()
	tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).\
		set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	is_dashing = false
	dashing_target = Vector2.ZERO
	emit_signal("dash_finished")

func update_dash(delta: float) -> void:
	velocity = (current_target - position).normalized() * (DASH_LENGTH / DASH_DURATION_SECONDS)
	move_and_collide(velocity * delta)
