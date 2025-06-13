extends Node

var base_damage_image : Image
var car_size := Vector2i.ZERO
var car_damage_images : Dictionary = {}


func _init() -> void:
	var template := preload("res://car/images/car_red_2.png").get_image()
	car_size = template.get_size()
	base_damage_image = Image.create_empty(car_size.x, car_size.y, false, Image.FORMAT_BPTC_RGBA)
	base_damage_image.decompress()
	for x in car_size.x:
		for y in car_size.y:
			if template.get_pixel(x, y).a > 0.25:
				base_damage_image.set_pixel(x, y, Color(0.0, 0.0, 1.0, 1.0))
			else:
				base_damage_image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))


func log_car(index: int) -> void:
	car_damage_images[index] = base_damage_image.duplicate()


func get_value(index: int, position: Vector2) -> Color:
	if point_in_bounds(position):
		return car_damage_images[index].get_pixelv(position)
	else:
		return Color(0.0, 0.0, 0.0, 0.0)


func point_in_bounds(position: Vector2) -> bool:
	return position.x >= 0 and position.x < car_size.x and \
		position.y >= 0 and position.y < car_size.y


func point_exists(index: int, position: Vector2) -> bool:
	var value := get_value(index, position)
	return point_in_bounds(position) and value.a > 0.0 and value.r < value.b


func damage_car(index: int, amount: float, offset: Vector2, radius := 10) -> void:
	var position := offset + Vector2(car_size) / 2
	for x in range(position.x - radius, position.x + radius):
		for y in range(position.y - radius, position.y + radius):
			if point_exists(index, Vector2(x, y)):
				var current_value := get_value(index, Vector2(x, y))
				current_value.r += amount
				car_damage_images[index].set_pixel(x, y, current_value)


func generate_car_texture(index: int) -> ImageTexture:
	return ImageTexture.create_from_image(car_damage_images[index])
