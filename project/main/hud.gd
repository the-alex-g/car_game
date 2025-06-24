extends CanvasLayer

@onready var _score_label_container := $ScoreLabelContainer


func _process(_delta: float) -> void:
	for i in 4:
		_score_label_container.get_child(i).text = "Player %d: %d kills" % [i, DamageHandler.get_score(i)]
