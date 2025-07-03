extends Control

var _player_colors := [
	Color.RED,
	Color(0.4, 0.4, 1.0, 1.0),
	Color.hex(0xabababff),
	Color.hex(0x00df00ff),
	Color.hex(0xf0de00ff),
	Color.hex(0xe6e6e6ff),
	Color.hex(0xd600fcff),
]
var _player_data := {}

@onready var _player_screen_container : HBoxContainer = $PlayerContainer


func _ready() -> void:
	for child: Control in _player_screen_container.get_children():
		child.hide()


func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_A:
				_join_player(event.device)
			if _is_player_joined(event.device):
				match event.button_index:
					JOY_BUTTON_DPAD_LEFT:
						_change_player_color(event.device, false)
					JOY_BUTTON_DPAD_RIGHT:
						_change_player_color(event.device)
					JOY_BUTTON_START:
						_start_game()
		if event is InputEventKey:
			if event.keycode == KEY_J:
				_join_player(mini(3, _player_data.size()))
			if _is_player_joined(0):
				if event.keycode == KEY_A:
					_change_player_color(0, false)
				elif event.keycode == KEY_D:
					_change_player_color(0)
			if event.keycode == KEY_ENTER:
				_start_game()


func _is_player_joined(index: int) -> bool:
	return _player_data.has(index)


func _join_player(index: int) -> void:
	if _is_player_joined(index):
		return
	
	_player_data[index] = {"color":-1}
	
	_player_screen_container.get_child(index).show()
	_set_player_color(index, _find_next_unused_color_index(0))


func _find_next_unused_color_index(from: int, direction := 1) -> int:
	var color_index := from
	while _is_color_used(color_index):
		color_index += direction
		if color_index < 0:
			color_index = _player_colors.size() - 1
		elif color_index == _player_colors.size():
			color_index = 0
	return color_index


func _is_color_used(index: int) -> bool:
	for player in _player_data:
		if _player_data[player].color == index:
			return true
	return false


func _change_player_color(index: int, forward := true) -> void:
	var direction := 1 if forward else -1
	_set_player_color(
		index,
		_find_next_unused_color_index(_player_data[index].color, direction)
	)


func _set_player_color(index: int, color: int) -> void:
	_player_data[index].color = color
	_player_screen_container.get_child(index).set_color(_player_colors[color])


func _start_game() -> void:
	for x in _player_data:
		_player_data[x].color = _player_colors[_player_data[x].color]
	DamageHandler.log_cars(_player_data)
	get_tree().change_scene_to_file("res://main/main.tscn")
