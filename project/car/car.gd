extends CharacterBody2D

# car movement based on this video: https://www.youtube.com/watch?v=mJ1ZfGDTMCY

@export var wheel_base := 8.0
@export var steering_angle := PI / 30
@export var engine_power := 400.0
@export var friction := 0.9
@export var drag := 0.001
@export var braking := 300.0
@export var max_speed_reverse := 150.0

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
		velocity = -velocity / 2.0


func _get_input() -> void:
	var turn := Input.get_axis("left", "right")
	_steer_direction = turn * steering_angle
	if Input.is_action_pressed("forward"):
		_acceleration = transform.x * engine_power
	if Input.is_action_pressed("backward"):
		_acceleration = transform.x * -braking


func _apply_friction() -> void:
	if velocity.length_squared() < 1.0:
		velocity = Vector2.ZERO
	var friction_force := velocity * friction
	var drag_force := velocity * velocity.length() * drag
	_acceleration -= (drag_force + friction_force)


func _calculate_steering(delta: float) -> void:
	var rear_wheel := position - transform.x * wheel_base / 2
	var front_wheel := position + transform.x * wheel_base / 2
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(_steer_direction) * delta
	var heading := (front_wheel - rear_wheel).normalized()
	var dot_product := heading.dot(velocity.normalized())
	if dot_product > 0:
		velocity = heading * velocity.length()
	elif dot_product < 0:
		velocity = -heading * minf(velocity.length(), max_speed_reverse)
	rotation = heading.angle()
