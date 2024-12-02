extends Control


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	GameManager._init_game()
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	pass # Replace with function body.
