extends Control

signal exited

@export var winner_label_settings := LabelSettings.new()

var _exitable := false

@onready var _dead_time_timer : Timer = $DeadTimeTimer
@onready var _instrux_label : Label = $Label2


func _ready() -> void:
	$Label.label_settings = winner_label_settings


func _input(event: InputEvent) -> void:
	if event.is_pressed() and visible and _exitable:
		exited.emit()
		hide()


func open_screen(winner: Car) -> void:
	_exitable = false
	_instrux_label.hide()
	show()
	winner_label_settings.font_color = winner.color
	_dead_time_timer.start()


func _on_timer_timeout() -> void:
	_instrux_label.show()
	_exitable = true
