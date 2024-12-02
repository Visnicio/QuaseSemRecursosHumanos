extends Node2D


@onready var end_day: Button = $CanvasLayer/MainUI/EndDay
@onready var end_turn: Button = $CanvasLayer/MainUI/EndTurn
@onready var cards_left: Label = $CanvasLayer/MainUI/Drawer/CardsLeft
@onready var current_day_display: RichTextLabel = $CanvasLayer/MainUI/CurrentDayDisplay

func _ready() -> void:
	GameManager.draw_hand()
	
func _process(delta: float) -> void:
	if GameManager.player_hand == []:
		end_day.disabled = false
		if GameManager.remaining_cards > 0:
			end_turn.disabled = false
	else:
		end_day.disabled = true
		end_turn.disabled = true
	
	cards_left.text = str(GameManager.remaining_cards)
	current_day_display.text = "[wave][center] Dia atual: %s [center][wave]" % GameManager.current_day


func _on_end_turn_pressed() -> void:
	for employee in GameManager.employees:
		employee.blocked = false
	GameManager.draw_hand()


func _on_end_day_pressed() -> void:
	GameManager.go_to_end_day()
