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
				base_damage_image.set_pixel(
					x,
					y,
					Color(0.0, 0.0, maxf(0.5, float(x) / car_size.x), 1.0)
				)
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
	var position := Vector2i(offset) + car_size / 2
	var frontier : Array[Vector3i] = [Vector3i(0, position.x, position.y)]
	var visited : Array[Vector2i] = []
	var visited_count := 0
	
	var impact_point := position
	if not point_exists(index, position):
		impact_point = Vector2i.MAX
	
	while not frontier.is_empty() and visited_count < roundi(PI * pow(radius, 2.0)):
		var info : Vector3i = frontier.pop_front()
		var current := Vector2i(info.y, info.z)
		if not current in visited:
			visited.append(current)
			if point_exists(index, current):
				if impact_point == Vector2i.MAX:
					impact_point = current
				visited_count += 1
				var current_value := get_value(index, current)
				current_value.r += clampf(
					amount * (1.0 - current.distance_squared_to(impact_point) / pow(radius, 2.0)),
					0.0,
					1.0
				)
				car_damage_images[index].set_pixelv(current, current_value)
		
			for direction : Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
				var new := current + direction
				if not new in visited:
					var heuristic : int = 0
					if impact_point != Vector2i.MAX:
						heuristic = roundi(new.distance_squared_to(impact_point))
					var insertion_index := 0
					for cell in frontier:
						if cell.x > heuristic:
							break
						insertion_index += 1
					frontier.insert(insertion_index, Vector3i(heuristic, new.x, new.y))


func generate_car_texture(index: int) -> ImageTexture:
	return ImageTexture.create_from_image(car_damage_images[index])
