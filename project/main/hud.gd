extends CanvasLayer

signal game_continued

@onready var _score_label_container := $ScoreLabelContainer


func _process(_delta: float) -> void:
	for i in DamageHandler.players:
		_score_label_container.get_child(i).text = "Player %d: %d kills" % [i, DamageHandler.get_score(i)]


func _on_main_game_ended(winner: Car) -> void:
	$EndGameScreen.open_screen(winner)


func _on_end_game_screen_exited() -> void:
	game_continued.emit()
