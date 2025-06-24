extends Node2D

@onready var _spawn_points := $SpawnPointContainer.get_children()
@onready var _car_container := $CarContainer


func _ready() -> void:
	for x in 4:
		_add_car(x)


func _add_car(index: int) -> void:
	var car := preload("res://car/car.tscn").instantiate()
	_car_container.add_child(car)
	car.global_transform = _spawn_points[index].global_transform
	car.index = index
	car.respawn_requested.connect(_add_car.bind(index))
