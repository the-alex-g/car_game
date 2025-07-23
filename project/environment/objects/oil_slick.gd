@tool
extends Area2D

@export_tool_button("splash") var foo := splash
@export var color := Color(0.1, 0.1, 0.15)
@export var physics := PhysicsMod.new()
@export var min_radius := 30
@export var max_radius := 70
@export var points := 64
@export var frequency := 1.0

var _shape : PackedVector2Array = []
var _config : PackedVector2Array = []
var _percent_spread := 0.0

@onready var _collision_polygon : CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	set_instance_shader_parameter("offset", Vector2(randf(), randf()) * 4.0)
	splash()


func _process(_delta: float) -> void:
	if _percent_spread < 1.0:
		_shape = []
		for point in _config:
			_shape.append(
				Vector2.RIGHT.rotated(point.x) * lerpf(10.0, lerpf(min_radius, max_radius, point.y), _percent_spread)
			)
		_collision_polygon.polygon = _shape
		queue_redraw()


func splash() -> void:
	_config = []
	_percent_spread = 0.0
	
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = frequency
	var image := noise.get_seamless_image(points, 1)
	
	for i in points:
		_config.append(
			Vector2(TAU * i / points, _average(image.get_pixel(i, 0)))
		)
	
	get_tree().create_tween().tween_property(self, "_percent_spread", 1.0, 1.0).set_trans(Tween.TRANS_QUAD)


func _average(c: Color) -> float:
	return (c.r + c.g + c.b) / 3


func _on_body_entered(body: Node2D) -> void:
	if body is Car:
		body.physics.merge_with(physics)


func _on_body_exited(body: Node2D) -> void:
	if body is Car:
		body.physics.unmerge(physics)


func _draw() -> void:
	if _shape.size() >= 3:
		draw_colored_polygon(_shape, color)
