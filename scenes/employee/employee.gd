extends Node2D
class_name Employee

@onready var employee_display: TextureRect = $EmployeeDisplay

@onready var portrait_image: TextureRect = $EmployeeDisplay/Portrait/PortraitImage
@onready var productivity_bar: ProgressBar = $Productivity
@onready var stress_bar: ProgressBar = $Stress
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var image: Texture2D
@export var employee_name: String

@export var start_stress: float
@export var start_productivity: float

var stress: float = 0
var temp_stress: float = 0
var productivity: float = 0
var temp_productivity: float = 0

var blocked: bool = false
@onready var blocked_display: Panel = $BlockedDisplay

var internal_delta: float = 0

func _ready() -> void:
	blocked = false
	GameManager.employees.append(self)
	randomize_stats()
	stress = start_stress
	productivity = start_productivity
	
	var existing_employee_data = GameManager.employee_dataset.get(employee_name)
	if existing_employee_data != null:
		stress = existing_employee_data.stress
		productivity = existing_employee_data.productivity
	
	
	portrait_image.texture = image
	productivity_bar.value = productivity
	stress_bar.value = stress
	
	SignalBus.apply_employee_preview_effects.connect(_on_apply_employee_preview_effects)
	SignalBus.remove_employee_preview_effects.connect(_on_remove_employee_preview_effects)
	SignalBus.apply_effects_to_employee.connect(_on_apply_effects_to_employee)

var elapsed_time: float

func _process(delta: float) -> void:
	internal_delta = delta
	productivity = clamp(productivity, productivity_bar.min_value, productivity_bar.max_value)
	stress = clamp(stress, stress_bar.min_value, stress_bar.max_value)
	
	blocked_display.visible = blocked


func shake() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(employee_display, "rotation_degrees", 0, .2).from(-15)
	tween.parallel().tween_property(employee_display, "scale", Vector2(1.1,1.1), .2).from(Vector2(.6,.6))
	tween.parallel().tween_property(employee_display, "scale", Vector2(1,1), .2).from(Vector2(.6,.6))


func _exit_tree() -> void:
	GameManager.employees.erase(self)


func randomize_stats() -> void:
	randomize()
	start_productivity = randf_range(0, 70)
	start_stress = randf_range(0, 70)


func _on_apply_employee_preview_effects(card_to_preview: Card, employee_to_preview: Employee) -> void:
	if employee_to_preview == self:
		SoundManager.play_sound("res://assets/sfx/hover_card.wav", "sfx")
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.parallel().tween_property(employee_display, "scale", Vector2(1.1,1.1), .2).from(Vector2(.6,.6))
		
		temp_productivity = productivity + card_to_preview.data.productivity_gain
		temp_stress = stress + card_to_preview.data.stress_gain
		
		var bars_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		bars_tween.parallel().tween_property(productivity_bar, "value", temp_productivity, .2).from(productivity_bar.value)
		bars_tween.parallel().tween_property(stress_bar, "value", temp_stress, .2).from(stress_bar.value)

func _on_remove_employee_preview_effects(card_to_undo: Card, employee_to_undo: Employee) -> void:
	if employee_to_undo == self:
		SoundManager.play_sound("res://assets/sfx/hover_2.wav", "sfx")
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.parallel().tween_property(employee_display, "scale", Vector2(1.0,1.0), .2).from(Vector2(.6,.6))
		
		temp_productivity = temp_productivity - card_to_undo.data.productivity_gain
		temp_stress = temp_stress - card_to_undo.data.stress_gain
		
		var bars_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		bars_tween.parallel().tween_property(productivity_bar, "value", temp_productivity, .2).from(productivity_bar.value)
		bars_tween.parallel().tween_property(stress_bar, "value", temp_stress, .2).from(stress_bar.value)


func _on_apply_effects_to_employee(card_to_use: Card, target_employee: Employee) -> void:
	if target_employee == self:
		productivity = temp_productivity
		stress = temp_stress
		
		var bars_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		bars_tween.parallel().tween_property(productivity_bar, "value", productivity, .2).from(productivity_bar.value)
		bars_tween.parallel().tween_property(stress_bar, "value", stress, .2).from(stress_bar.value)
		
		temp_productivity = 0
		temp_stress = 0
