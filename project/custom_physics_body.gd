class_name CustomPhysicsBody
extends CharacterBody2D

@export var friction := 0.9
@export var drag := 0.001
@export var disabled := false
@export var mass := 1.0
@export var bounciness := 1.0

var _acceleration := Vector2.ZERO
var _rotational_acceleration := 0.0
var _rotational_velocity := 0.0


func _physics_process(delta: float) -> void:
	_acceleration = Vector2.ZERO
	_rotational_acceleration = 0.0
	_resolve_custom_physics(delta)
	_apply_friction()
	velocity += _acceleration * delta
	_rotational_velocity += _rotational_acceleration * delta
	rotation += _rotational_velocity * delta
	var collision := move_and_collide(velocity * delta)
	if collision:
		var impulse := velocity * mass
		if collision.get_collider() is CustomPhysicsBody:
			var collider : CustomPhysicsBody = collision.get_collider()
			impulse -= collider.velocity
			impulse /= 2
			collider.apply_impulse(impulse, collision.get_position())
		apply_impulse(-impulse * bounciness, collision.get_position())


func _resolve_custom_physics(_delta: float) -> void:
	pass


func _apply_friction() -> void:
	if velocity.length_squared() < 1.0:
		velocity = Vector2.ZERO
	if absf(_rotational_velocity) < 0.01:
		_rotational_velocity = 0.0
	var friction_force := velocity * friction
	var drag_force := velocity * velocity.length() * drag
	_acceleration -= (drag_force + friction_force)
	_rotational_acceleration -= _rotational_velocity * friction


func apply_impulse(impulse: Vector2, at: Vector2) -> void:
	var offset := at - global_position
	impulse /= mass
	velocity += impulse
	var torque := (impulse - impulse.project(offset)).length() * offset.length()
	torque /= mass * 5
	_rotational_velocity += torque
