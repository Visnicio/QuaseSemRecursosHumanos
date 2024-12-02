extends Node

const CARD = preload("res://scenes/card/card.tscn")
var cards_resources: Array[CardResource] = [
	preload("res://core/feedback_session.tres"),
	preload("res://core/extra_hour.tres"),
	preload("res://core/feedback_session.tres"), 
	preload("res://core/final_sprint.tres"), 
	preload("res://core/hot_coffee.tres"),
	preload("res://core/simple_task.tres"), 
	preload("res://core/training_all_day.tres")
]

var employees: Array[Employee]

var current_day: int = 1
var game_end_day: int = 7
var project_progress: float = 0.0
var project_progress_quota: float = 400

var holding_card: Card = null
var player_hand: Array[Card] = []

var remaining_cards: int = 9

## Um dictionary contento um save temporatio pra cada employee, a chave é o nome do empregadoe, os valores sao a produtividade e estresse
var employee_dataset: Dictionary

var played_tutorial: bool = false

func _init_game() -> void:
	employee_dataset = {}
	current_day = 1
	project_progress = 0.0
	player_hand = []
	remaining_cards = 9

func process_end_day() -> void:
	var productivity_sum : float = 0
	
	for employee: Employee in employees:
		productivity_sum += employee.productivity
	
	var progress = productivity_sum / employees.size()
	project_progress += progress
	
	for employee in employees:
		add_employee_to_data(employee)
	
	
func go_to_end_day() -> void:
	process_end_day()
	get_tree().change_scene_to_file("res://scenes/day_end/day_end.tscn")

func draw_card() -> void:
	randomize()
	for holder in get_tree().get_nodes_in_group("card_positions"):
		if holder.get_child_count() == 0:
			var new_card = CARD.instantiate()
			var resource = cards_resources.pick_random()
			new_card.data = resource
			
			holder.add_child(new_card)
			SoundManager.play_sound("res://assets/sfx/drop_card.wav", "sfx")
			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(new_card, "global_position", holder.global_position, .1).from(get_tree().get_first_node_in_group("drawer").global_position)
			
			player_hand.append(new_card)
			remaining_cards -= 1
			return
			
	pass
	
func draw_hand() -> void:
	for i in 3:
		draw_card()
		await get_tree().create_timer(.3).timeout

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_draw"):
		draw_card()
	

func _ready() -> void:
	SoundManager.set_bg_music("res://assets/music/oberheimer.ogg", false)


func add_employee_to_data(employee_to_save: Employee) -> void:
	employee_dataset[employee_to_save.employee_name] = {
		"productivity": employee_to_save.productivity,
		"stress": employee_to_save.stress
	}
