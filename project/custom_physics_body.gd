class_name CustomPhysicsBody
extends CharacterBody2D

@export var physics := PhysicsMod.new()
@export var disabled := false
@export var center_of_mass_offset := Vector2.ZERO

var _acceleration := Vector2.ZERO
var _rotational_acceleration := 0.0
var _rotational_velocity := 0.0
var impulse : Vector2 :
	get():
		return velocity * physics.mass
	set(value):
		velocity = value / physics.mass
var global_center_of_mass : Vector2 :
	get():
		return center_of_mass_offset + global_position
var center_of_mass : Vector2 :
	get():
		return center_of_mass_offset + position


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
		var collision_impulse := impulse
		if collision.get_collider() is CustomPhysicsBody:
			var collider : CustomPhysicsBody = collision.get_collider()
			collision_impulse -= collider.impulse
			collider.apply_impulse(collision_impulse / 2, collision.get_position())
		apply_impulse(-collision_impulse / 2, collision.get_position())


func _resolve_custom_physics(_delta: float) -> void:
	pass


func _apply_friction() -> void:
	if velocity.length_squared() < 1.0:
		velocity = Vector2.ZERO
	if absf(_rotational_velocity) < 0.01:
		_rotational_velocity = 0.0
	var friction_force := velocity * physics.friction
	var drag_force := velocity * velocity.length() * physics.drag
	_acceleration -= (drag_force + friction_force)
	_rotational_acceleration -= _rotational_velocity * physics.friction


func apply_impulse(applied_impulse: Vector2, at: Vector2) -> Vector2:
	var offset := at - global_center_of_mass
	applied_impulse *= physics.bounciness / physics.mass
	velocity += applied_impulse
	var torque := (applied_impulse - applied_impulse.project(offset)).length() * \
		offset.length()
	torque /= physics.mass * 5
	_rotational_velocity += torque
	
	return applied_impulse
