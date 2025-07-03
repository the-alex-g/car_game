extends Control

signal exited

var _exitable := false

@onready var _dead_time_timer : Timer = $DeadTimeTimer
@onready var _instrux_label : Label = $Label2


func _input(event: InputEvent) -> void:
	if event.is_pressed() and visible and _exitable:
		exited.emit()
		hide()


func open_screen(_winner: Car) -> void:
	show()
	_dead_time_timer.start()


func _on_timer_timeout() -> void:
	_instrux_label.show()
	_exitable = true
