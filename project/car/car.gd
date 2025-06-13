class_name Car
extends CharacterBody2D

# car movement from this video: https://www.youtube.com/watch?v=mJ1ZfGDTMCY

@export var wheel_base := 8.0
@export var steering_angle := PI / 30
@export var engine_power := 300.0
@export var friction := 0.9
@export var drag := 0.001
@export var braking := 100.0
@export var max_speed_reverse := 100.0
@export var sideways_push_resistance := 0.98
@export var index := 0
@export var disabled := false

var _acceleration := Vector2.ZERO
var _steer_direction := 0.0


func _physics_process(delta: float) -> void:
	_acceleration = Vector2.ZERO
	_get_input()
	_apply_friction()
	velocity += _acceleration * delta
	_calculate_steering(delta)
	var collision := move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider() is Car:
			collision.get_collider().velocity += velocity / 2.0
		velocity = -velocity / 2.0


func _get_input() -> void:
	if disabled:
		return
	
	var turn := Input.get_joy_axis(index, JOY_AXIS_LEFT_X)
	if index == 0 and turn == 0:
		turn = Input.get_axis("left", "right")
	_steer_direction = turn * steering_angle
	if Input.is_action_pressed("forward") and index == 0:
		_acceleration = transform.x * engine_power
	if Input.is_action_pressed("backward") and index == 0:
		_acceleration = -transform.x * braking
	
	if _acceleration == Vector2.ZERO:
		var input := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		if input < -0.1:
			_acceleration = -braking * transform.x
		elif input > 0.1:
			_acceleration = engine_power * transform.x


func _apply_friction() -> void:
	if velocity.length_squared() < 1.0:
		velocity = Vector2.ZERO
	var friction_force := velocity * friction
	var drag_force := velocity * velocity.length() * drag
	_acceleration -= (drag_force + friction_force)


func _calculate_steering(delta: float) -> void:
	var front_wheel := transform.x * wheel_base / 2
	var rear_wheel := -front_wheel + velocity * delta
	front_wheel += velocity.rotated(_steer_direction) * delta
	var heading := (front_wheel - rear_wheel).normalized()
	var dot_product := heading.dot(velocity.normalized())
	var forward_speed := velocity.project(transform.x).length()
	var sideways_velocity := velocity.project(transform.y)
	if dot_product > 0:
		velocity = heading * forward_speed
	elif dot_product < 0:
		velocity = -heading * minf(forward_speed, max_speed_reverse)
	velocity += sideways_velocity * sideways_push_resistance
	rotation = heading.angle()
