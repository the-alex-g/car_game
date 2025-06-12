extends CharacterBody2D

# car movement based on this video: https://www.youtube.com/watch?v=mJ1ZfGDTMCY

@export var wheel_base := 8.0
@export var steering_angle := PI / 30
@export var engine_power := 400.0
@export var friction := 0.9
@export var drag := 0.001
@export var braking := 300.0
@export var max_speed_reverse := 150.0

var _acceleration := 0.0
var _steer_direction := 0.0
var _speed := 0.0 :
	set(value):
		_speed = max(value, -max_speed_reverse)


func _physics_process(delta: float) -> void:
	_acceleration = 0.0
	_get_input()
	_apply_friction()
	_speed += _acceleration * delta
	_calculate_steering(delta)
	var collision := move_and_collide(transform.x * _speed * delta)
	if collision:
		_speed = -_speed / 2.0
		_acceleration = 0.0


func _get_input() -> void:
	var turn := Input.get_axis("left", "right")
	_steer_direction = turn * steering_angle
	if Input.is_action_pressed("forward"):
		_acceleration = engine_power
	if Input.is_action_pressed("backward"):
		_acceleration = -braking


func _apply_friction() -> void:
	if absf(_speed) < 5.0:
		_speed = 0.0
	var friction_force := absf(_speed) * friction
	var drag_force := pow(absf(_speed), 2.0) * drag
	_acceleration -= (drag_force + friction_force) * signf(_speed)


func _calculate_steering(delta: float) -> void:
	var rear_wheel := position - transform.x * wheel_base / 2
	var front_wheel := position + transform.x * wheel_base / 2
	rear_wheel += transform.x * _speed * delta
	front_wheel += transform.x.rotated(_steer_direction) * delta * _speed
	var heading := (front_wheel - rear_wheel).normalized()
	velocity = heading * _speed
	rotation = heading.angle()
