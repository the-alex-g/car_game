class_name Car
extends CustomPhysicsBody

# car movement from this video: https://www.youtube.com/watch?v=mJ1ZfGDTMCY

signal died

@export var wheel_base := 8.0
@export var steering_angle := PI / 30
@export var engine_power := 350.0
@export var braking := 100.0
@export var max_speed_reverse := 100.0
@export var sideways_push_resistance := 0.02
@export var color : Color :
	get():
		return DamageHandler.get_car_color(index)
@export var index := 0

var _steer_direction := 0.0
var _dead := false

@onready var _sprite : Sprite2D = $Sprite2D


func _ready() -> void:
	_initialize_shader()


func _initialize_shader() -> void:
	var shader_material := ShaderMaterial.new()
	shader_material.shader = preload("res://car/car.gdshader")
	_sprite.material = shader_material
	_sprite.set_instance_shader_parameter(
		"chassis_color",
		color
	)
	_sprite.material.set_shader_parameter("damage", DamageHandler.generate_car_texture(index))


func _resolve_custom_physics(delta: float) -> void:
	_get_input()
	_calculate_steering(delta)


func _get_input() -> void:
	if Input.is_action_just_pressed("die"):
		die()
	
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
		var input := -Input.get_joy_axis(index, JOY_AXIS_RIGHT_Y)
		if input < -0.1:
			_acceleration = -braking * transform.x
		elif input > 0.1:
			_acceleration = engine_power * transform.x


func _calculate_steering(delta: float) -> void:
	var front_wheel := transform.x * wheel_base / 2
	var rear_wheel := -front_wheel + velocity * delta
	front_wheel += velocity.rotated(_steer_direction) * delta
	var heading : Vector2 = lerp(transform.x, front_wheel - rear_wheel, physics.friction).normalized()
	
	var dot_product := heading.dot(velocity.normalized())
	var forward_speed := velocity.project(transform.x).length()
	var sideways_velocity := velocity.project(transform.y)
	if dot_product > 0:
		velocity = heading * forward_speed
	elif dot_product < 0:
		velocity = -heading * minf(forward_speed, max_speed_reverse)
	velocity += sideways_velocity * (1.0 - sideways_push_resistance)
	rotation = heading.angle() + _rotational_velocity * delta


func _damage_self(magnitude: float, at: Vector2) -> bool:
	var died_this_turn := DamageHandler.damage_car(
		index,
		magnitude,
		(at - global_position).rotated(-rotation)
	)
	_sprite.material.set_shader_parameter("damage", DamageHandler.generate_car_texture(index))
	return died_this_turn


func apply_impulse(applied_impulse: Vector2, at: Vector2) -> Vector2:
	applied_impulse = super.apply_impulse(applied_impulse, at)
	
	var died_this_turn := _damage_self(applied_impulse.length() / 200, at)
	
	if not _dead:
		_dead = died_this_turn
		if _dead:
			die()
	
	return applied_impulse


func die() -> void:
	disabled = true
	var explosion := preload("res://explosions/explosion.tscn").instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_position = global_position
	await get_tree().create_timer(0.1).timeout
	_sprite.material.set_shader_parameter("destroyed", true)
	$SmokeParticles.emitting = true
	died.emit()
