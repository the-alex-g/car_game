extends Control

@onready var _texture_rect : TextureRect = $VBoxContainer/TextureRect


func set_color(color: Color) -> void:
	_texture_rect.set_instance_shader_parameter("chassis_color", color)
