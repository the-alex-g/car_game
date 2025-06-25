extends Node2D

const MIN_ZOOM_THRESHOLD := 0.33

@onready var _spawn_points := $SpawnPointContainer.get_children()
@onready var _car_container := $CarContainer
@onready var _camera : Camera2D = $Camera2D

var _screen_size := Vector2(DisplayServer.screen_get_size())
var _car_count := 0


func _ready() -> void:
	_start_game()


func _process(_delta: float) -> void:
	_position_camera()


func _position_camera() -> void:
	var current_camera_position := _camera.position
	var min_x := INF
	var min_y := INF
	var max_x := 0.0
	var max_y := 0.0
	var average := Vector2.ZERO
	
	for car : Car in _car_container.get_children():
		if not car.disabled:
			min_x = minf(car.global_position.x, min_x)
			min_y = minf(car.global_position.y, min_y)
			max_x = maxf(car.global_position.x, max_x)
			max_y = maxf(car.global_position.y, max_y)
			average += car.global_position
	average /= 4
	
	
	var rect := Rect2(min_x - 100, min_y - 100, max_x - min_x + 200, max_y - min_y + 200)
	var new_center := rect.get_center()
	
	if new_center.distance_to(current_camera_position) > 10:
		create_tween().tween_property(_camera, "position", new_center, 0.3)
	else:
		_camera.position = new_center
	
	var zoom := (rect.size.x + rect.size.y) / _screen_size.y
	_camera.zoom = Vector2.ONE / zoom
	
	for car : Car in _car_container.get_children():
		if not car.disabled:
			if car.global_position.distance_to(average) > 1000:
				car.die()


func _add_car(index: int) -> void:
	var car := preload("res://car/car.tscn").instantiate()
	_car_container.add_child(car)
	car.global_position = _spawn_points[index].global_position
	car.rotation = PI / 4 + index * PI / 2
	car.index = index
	_car_count += 1
	car.died.connect(
		func():
			_car_count -= 1
			if _car_count == 1:
				_game_over()
	)


func _game_over() -> void:
	for car in _car_container.get_children():
		car.queue_free()
	_start_game()


func _start_game() -> void:
	_car_count = 0
	for x in 4:
		_add_car(x)
