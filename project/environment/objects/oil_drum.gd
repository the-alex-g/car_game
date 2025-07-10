extends CustomPhysicsBody

@export var break_threshold := 250.0

var _drained := false

@onready var _sprite : Sprite2D = $Sprite2D


func _ready() -> void:
	_sprite.set_instance_shader_parameter("noise_offset", Vector2(
		randf(), randf()
	) * 4.0)


func apply_impulse(impulse: Vector2, at: Vector2) -> Vector2:
	impulse = super.apply_impulse(impulse, at)
	
	if impulse.length() > break_threshold and not _drained:
		_spill()
	
	return impulse


func _spill() -> void:
	_drained = true
	var oil_slick := preload("res://environment/objects/oil_slick.tscn").instantiate()
	get_parent().add_child(oil_slick)
	oil_slick.global_position = global_position
