@tool
class_name Enemy
extends CharacterBody2D

@export_group("Behavior Testing")
@export var dash_button := false:
	set(value):
		dash_attack()
		action_state = ACTION_STATES.Dash_Attack
		debug_dashing = true
		await dash_cooldown_finished
		debug_dashing = false

@export_group("Parameters")
@export var ACTIVE := false
@export var BASE_SPEED := 600
@export var HP := 3:
	set(value):
		HP = value
		$hp_label_temp.text = "HP: " + str(value)
		if value == 0:
			queue_free()
@export var DASH_LENGTH := 350
@export var DASH_DURATION_SECONDS := 0.2
@export var DASH_COOLDOWN_SECONDS := 0.3
@export var KEEP_DISTANCE_FROM_PLAYER := 500

signal dash_finished
signal dash_cooldown_finished

var debug_dashing := false
var dashing_target := Vector2.ZERO
var current_target := Vector2.ZERO
var dash_time_elapsed: float = 0.0
var previous_position: Vector2

enum ACTION_STATES {
	Idle,
	Chase,
	Dash_Catchup,
	Dash_Attack_Windup,
	Dash_Attack,
	Dash_Attack_Followthrough,
}

@export var action_state := ACTION_STATES.Idle

func _ready() -> void:
	HP = HP

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if debug_dashing:
		update_dash(delta)
	
	if not ACTIVE:
		return
	
	match action_state:
		ACTION_STATES.Idle:
			move_and_collide(velocity * delta)
			velocity = Vector2.ZERO
		ACTION_STATES.Chase:
			velocity = position.direction_to(Global.Player.position)
			move_and_collide(velocity * BASE_SPEED * delta)
			
			if position.distance_to(Global.Player.position) < KEEP_DISTANCE_FROM_PLAYER:
				action_state = ACTION_STATES.Dash_Attack_Windup
		ACTION_STATES.Dash_Attack_Windup:
			dash_attack()
		ACTION_STATES.Dash_Attack:
			update_dash(delta)
		ACTION_STATES.Dash_Attack_Followthrough:
			pass

func dash_attack() -> void:
	$AnimationPlayer.play("windup")
	await $AnimationPlayer.animation_finished
	action_state = ACTION_STATES.Dash_Attack
	dash()
	await dash_finished
	dash_cooldown()
	await dash_cooldown_finished
	action_state = ACTION_STATES.Chase
	pass

func dash() -> void:
	if not debug_dashing:
		start_dash()

func dash_cooldown() -> void:
	var timer := get_tree().create_timer(DASH_COOLDOWN_SECONDS)
	await timer.timeout
	emit_signal("dash_cooldown_finished")
	pass

func start_dash() -> void:
	dashing_target = position + position.direction_to(Global.Player.position) * DASH_LENGTH
	current_target = position
	dash_time_elapsed = 0.0
	previous_position = position
	
	var tween := create_tween()
	tween.tween_property(self, "current_target", dashing_target, DASH_DURATION_SECONDS).\
		set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	await tween.finished
	
	dashing_target = Vector2.ZERO
	emit_signal("dash_finished")

func update_dash(delta: float) -> void:
	dash_time_elapsed += delta
	if dash_time_elapsed > DASH_DURATION_SECONDS:
		dash_time_elapsed = DASH_DURATION_SECONDS  # Clamp to max duration
	
	# Calculate velocity based on the change in position
	var new_position := previous_position.lerp(current_target, dash_time_elapsed / DASH_DURATION_SECONDS)
	velocity = (new_position - position) / delta
	
	move_and_collide(velocity * delta)
	previous_position = new_position

func push(push_vector: Vector2) -> void:
	velocity += push_vector

func _on_projectile_hitbox_body_entered(body: Node2D) -> void:
	HP -= 1
	pass # Replace with function body.
