extends Control

@onready var project_progress: ProgressBar = $ProjectProgress
@onready var remaining_days: Label = $RemainingDays
@onready var game_lost_modal: Panel = $GameLostModal

@onready var modal_title: Label = $GameLostModal/Title
@onready var desc_1: Label = $GameLostModal/Desc1
@onready var desc_2: Label = $GameLostModal/Desc2

func _ready() -> void:
	$InitNextDay.disabled = false
	
	project_progress.max_value = GameManager.project_progress_quota
	remaining_days.text = "Dias Restantes: %s" % (GameManager.game_end_day - GameManager.current_day)
	remaining_days.pivot_offset = remaining_days.get_rect().size / 2
	show_progress()
	pass
	
func show_progress() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

	tween.tween_property(project_progress, "value", GameManager.project_progress, .2)

func init_next_day() -> void:
	$ExplosionGravity.emitting = true

	$InitNextDay.disabled = true
	SoundManager.play_sound("res://assets/sfx/explosion2.wav", "sfx")
	GameManager.current_day += 1
	
	
			
	
	GameManager.remaining_cards += 6 # os 3 necessarios para uma hand inicial e 3 adicionais
	remaining_days.text = "Dias Restantes: %s" % (GameManager.game_end_day - GameManager.current_day)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(remaining_days, "rotation_degrees", 0, .2).from(-15)
	tween.parallel().tween_property(remaining_days, "scale", Vector2(1.1,1.1), .2).from(Vector2(.6,.6))
	tween.parallel().tween_property(remaining_days, "scale", Vector2(1,1), .2).from(Vector2(.6,.6))
	
	# Check if player lost
	if check_for_game_end():
		return
	
	tween.tween_callback(func():
		await get_tree().create_timer(2).timeout
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
		)
	


func _on_init_next_day_pressed() -> void:
	init_next_day()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")


func check_for_game_end() -> bool:
	var end: bool = false
	
	var lost_by_burnout: bool = false
	var title: String
	var title_color: Color
	var description1: String
	var description2: String
	
	var employees_dataset = GameManager.employee_dataset
	for employee_name in employees_dataset.keys():
		var employee_data: Dictionary = employees_dataset[employee_name]
		if employee_data.stress >= 100:
			
			lost_by_burnout = true
	
	if GameManager.game_end_day - GameManager.current_day < 0:
		# Perdeu por tempo
		title = "Você foi DEMITIDO"
		title_color = Color.FIREBRICK
		description1 = "O prazo de entrega chegou e nada foi entrege."
		description2 = "Os diretores ficaram desapontados com seu 
		desempenho e te dispensaram do serviço."
		end = true
	elif lost_by_burnout:
		title = "Você foi DEMITIDO"
		title_color = Color.FIREBRICK
		description1 = "Um de seus funcionários teve um burnout."
		description2 = "Um processo foi aberto contra a empresa e você foi demitido."
		end = true
	elif GameManager.project_progress >= GameManager.project_progress_quota:
		title = "Você ENTREGOU o projeto a tempo"
		title_color = Color.SKY_BLUE
		description1 = "Parabéns! Você conseguiu fazer com que a equipe entregasse o projeto a tempo."
		description2 = "Como reconhecimento de seu esforço arduo você foi 
		presenteado com um mimo da empresa! Aproveite seu sonho de valsa :)"
		end = true
	
	if end:
		modal_title.text = title
		modal_title.modulate = title_color
		desc_1.text = description1
		desc_2.text = description2
		var tween_modal = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween_modal.tween_property(game_lost_modal, "position", Vector2(376, 224), .3).from(Vector2(376, 736))
		$InitNextDay.disabled = true
		return true
	else:
		return false
