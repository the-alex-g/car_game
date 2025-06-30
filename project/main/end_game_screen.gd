extends Control

signal exited


func _input(event: InputEvent) -> void:
	if event.is_pressed() and visible:
		exited.emit()
		hide()


func open_screen(winner: Car) -> void:
	show()
