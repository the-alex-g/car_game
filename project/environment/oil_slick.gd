@tool
extends Area2D

@export_tool_button("splash") var foo := splash
@export var physics := PhysicsMod.new()
@export var min_radius := 30
@export var max_radius := 70
@export var points := 64
@export var frequency := 1.0

var _shape : PackedVector2Array = []

@onready var _collision_polygon : CollisionPolygon2D = $CollisionPolygon2D


func _ready() -> void:
	splash()


func splash() -> void:
	scale = Vector2(0.2, 0.2)
	_shape = []
	
	var noise := FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = frequency
	var image := noise.get_seamless_image(points, 1)
	
	for i in points:
		_shape.append(
			Vector2.RIGHT.rotated(TAU * i / points) * lerpf(min_radius, max_radius, _average(image.get_pixel(i, 0)))
		)
	
	_collision_polygon.polygon = _shape
	queue_redraw()
	
	get_tree().create_tween().tween_property(self, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_QUAD)


func _average(color: Color) -> float:
	return (color.r + color.g + color.b) / 3


func _on_body_entered(body: Node2D) -> void:
	if body is Car:
		body.physics.merge_with(physics)


func _on_body_exited(body: Node2D) -> void:
	if body is Car:
		body.physics.unmerge(physics)


func _draw() -> void:
	draw_colored_polygon(_shape, Color(0.0, 0.0, 0.05, 1.0))
