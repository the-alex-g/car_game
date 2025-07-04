extends CanvasLayer

signal game_continued


func _on_main_game_ended(winner: Car) -> void:
	$EndGameScreen.open_screen(winner)


func _on_end_game_screen_exited() -> void:
	game_continued.emit()
