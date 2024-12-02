extends Node

var tweens = {}

func _ready() -> void:
	#apply_sounds_to_ui()
	pass

func apply_sounds_to_ui() -> void:
	apply_sounds(get_tree().get_root())

## Finds Every button and apply sounds to it
func apply_sounds(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			
			child.pivot_offset = child.get_rect().size / 2
			
			if !child.is_connected("mouse_entered", _play_hover_sound):
				child.mouse_entered.connect(_play_hover_sound)
			
			if !child.is_connected("focus_entered", _play_hover_sound):
				child.focus_entered.connect(_play_hover_sound)
				
			if !child.is_connected("pressed", _play_click_sound):
				child.pressed.connect(_play_click_sound)
		
		if child.get_child_count() > 0:
			apply_sounds(child)
			pass
	pass
	
func apply_effects(node: Control) -> void:
	for child in node.get_children():
		if child is Button:
			child.pivot_offset = child.get_rect().size / 2

			if !child.is_connected("mouse_entered", _apply_hover_effect):
				child.mouse_entered.connect(_apply_hover_effect.bind(child))
			
			if !child.is_connected("focus_entered", _apply_hover_effect):
				child.focus_entered.connect(_apply_hover_effect.bind(child))
				
			if !child.is_connected("mouse_exited", _apply_hover_exit):
				child.mouse_exited.connect(_apply_hover_exit.bind(child))
				
			if !child.is_connected("focus_exited", _apply_hover_exit):
				child.focus_exited.connect(_apply_hover_exit.bind(child))
		
		if child.get_child_count() > 0:
			apply_effects(child)
			pass
	pass


func _play_hover_sound() -> void:
	SoundManager.play_sound("res://assets/sfx/btn_hover.wav", "sfx")
	pass

func _play_click_sound() -> void:
	SoundManager.play_sound("res://assets/sfx/explosion2.wav", "sfx")
	pass

func _destroy_audio_player(audio_player: AudioStreamPlayer) -> void:
	if is_instance_valid(audio_player):
		audio_player.queue_free()

func _apply_hover_effect(node: Control) -> void:
	if tweens.has(node):
		tweens[node].kill()  # Mata o tween anterior se já existir

	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "rotation_degrees", 0, .2).from(-15)
	tween.parallel().tween_property(node, "scale", Vector2(1.1, 1.1), .2).from(Vector2(.8, .8))

	tweens[node] = tween  # Armazena o tween na lista

func _apply_hover_exit(node: Control) -> void:
	if tweens.has(node):
		tweens[node].kill()  # Mata o tween de hover anterior

	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(node, "rotation_degrees", 0, .2)
	tween.parallel().tween_property(node, "scale", Vector2(1.0, 1.0), .2)

	tweens[node] = tween  # Armazena o tween de hover exit
