extends Node2D

signal game_ended(winner: Car)

const CAR_CULL_DISTANCE := 1000
const SCREEN_MARGIN := 100
const TWEEN_THRESHOLD := 10
const SPAWN_DISTANCE := 400

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
	
	var rect := Rect2(
		min_x - SCREEN_MARGIN, min_y - SCREEN_MARGIN,
		max_x - min_x + SCREEN_MARGIN * 2,
		max_y - min_y + SCREEN_MARGIN * 2
	)
	var new_center := rect.get_center()
	
	if new_center.distance_to(current_camera_position) > TWEEN_THRESHOLD:
		create_tween().tween_property(_camera, "position", new_center, 0.3)
	else:
		_camera.position = new_center
	
	var zoom := (rect.size.x + rect.size.y) / _screen_size.y
	_camera.zoom = Vector2.ONE / zoom
	
	_cull_cars(average)


func _cull_cars(game_center: Vector2) -> void:
	for car : Car in _car_container.get_children():
		if not car.disabled:
			if car.global_position.distance_to(game_center) > CAR_CULL_DISTANCE:
				car.die()


func _add_car(index: int) -> void:
	var car := preload("res://car/car.tscn").instantiate()
	car.index = index
	_car_container.add_child(car)
	car.global_position = Vector2.RIGHT.rotated(index * TAU / _car_count) * SPAWN_DISTANCE
	car.rotation = index * TAU / _car_count
	car.died.connect(
		func():
			_car_count -= 1
			if _car_count <= 1:
				_game_over()
	)


func _game_over() -> void:
	for car : Car in _car_container.get_children():
		if not car.disabled:
			game_ended.emit(car)
			break


func _start_game() -> void:
	_remove_cars()
	_car_count = DamageHandler.players.size()
	for x in DamageHandler.players:
		_add_car(x)


func _remove_cars() -> void:
	for car in _car_container.get_children():
		car.queue_free()
	_car_count = 0


func _on_hud_game_continued() -> void:
	DamageHandler.reset_car_damage()
	_start_game()
