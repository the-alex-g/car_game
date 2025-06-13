extends Node

var base_damage_array : Array[PackedByteArray] = []
var car_size := Vector2.ZERO
var car_damage_arrays : Dictionary = {}


func _init() -> void:
	var car_template := preload("res://car/images/car_red_2.png").get_image()
	for x in car_template.get_size().x:
		car_size.y += 1
		var row : PackedByteArray = []
		for y in car_template.get_size().y:
			if car_template.get_pixel(x, y).a > 0.25:
				row.append(0b0000_0000)
			else:
				row.append(0b1000_0000)
		base_damage_array.append(row)
	car_size.x = base_damage_array[0].size()


func log_car(index: int) -> void:
	car_damage_arrays[index] = base_damage_array.duplicate(true)


func get_value(index: int, position: Vector2) -> int:
	if point_in_bounds(position):
		return car_damage_arrays[index][position.y][position.x]
	else:
		return 0


func point_in_bounds(position: Vector2) -> bool:
	return position.x >= 0 and position.x < car_size.x and \
		position.y >= 0 and position.y < car_size.y


func point_exists(index: int, position: Vector2) -> bool:
	return point_in_bounds(position) and not get_value(index, position) && 0b1000_0000


func damage_car(index: int, amount: float, offset: Vector2, radius := 10) -> void:
	var position := offset + car_size / 2
	for x in range(position.x - radius, position.x + radius):
		for y in range(position.y - radius, position.y + radius):
			if point_exists(index, Vector2(x, y)):
				car_damage_arrays[index][y][x] += roundi(amount * 0b0111_1111)


func generate_car_texture(index: int) -> ImageTexture:
	var image := Image.create_empty(car_size.x, car_size.y, false, Image.FORMAT_BPTC_RGBA)
	image.decompress()
	var y := 0
	for row : PackedByteArray in car_damage_arrays[index]:
		var x := 0
		for point in row:
			if !(point && 0b1000_0000):
				var value := point / float(0b0111_1111)
				image.set_pixel(x, y, Color(value, value, value, 1.0))
			x += 1
		y += 1
	return ImageTexture.create_from_image(image)
