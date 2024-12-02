extends Button
class_name Card

@export var title_label: Label

@export var is_dragging: bool = false
@export var employee_collision: CollisionShape2D
@export var employee_area: Area2D
var initial_position: Vector2
var mouse_offset: Vector2

@export var data: CardResource
var target_employee: Employee

@onready var stress_display: Label = $TextureRect/StressGain/StressDisplay
@onready var productivity_display: Label = $TextureRect/ProducitivyGain/ProductivityDisplay
@onready var image: TextureRect = $TextureRect/ImageFrame/Image
@onready var title: Label = $TextureRect/Description/Title

func _ready() -> void:
	pivot_offset = get_rect().size / 2
	initial_position = global_position
	
	stress_display.text = str(data.stress_gain)
	productivity_display.text = str(data.productivity_gain)
	image.texture = data.image
	title.text = data.display_name

func _process(delta: float) -> void:
	$TextureRect.pivot_offset = pivot_offset
	if is_dragging:
		global_position = get_global_mouse_position() - pivot_offset
		var angle = Input.get_last_mouse_velocity().x * 0.0005
		
		$TextureRect.rotation = lerp($TextureRect.rotation, angle, delta * 5.0)
		
		$TextureRect.rotation = clamp($TextureRect.rotation, deg_to_rad(-24), deg_to_rad(24))
	else:
		$TextureRect.rotation = lerp($TextureRect.rotation, 0.0, delta * 5.0)

func _on_button_down() -> void:
	SoundManager.play_sound("res://assets/sfx/pick_card.wav", "sfx")
	is_dragging = true
	GameManager.holding_card = self
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($TextureRect, "scale", Vector2(1.0, 1.0), 0.2)
	
	mouse_offset = get_global_mouse_position() - global_position

# Soltou a carta
func _on_button_up() -> void:
	GameManager.holding_card = null
	is_dragging = false
	
	if target_employee != null:
		target_employee.shake()
		target_employee.blocked = true
		GameManager.player_hand.erase(self)
		SignalBus.apply_effects_to_employee.emit(self, target_employee)
		queue_free()
	
	SoundManager.play_sound("res://assets/sfx/drop_card.wav", "sfx")
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "global_position", initial_position, 0.2)
	tween.tween_property($TextureRect, "scale", Vector2(1, 1), 0.2)
	tween.tween_callback( func() :
		)

#region Tween on Mouse Hover

func _on_mouse_entered() -> void:
	SoundManager.play_sound("res://assets/sfx/hover_card.wav", "sfx")
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($TextureRect, "scale", Vector2(1.3, 1.3), 0.2)


func _on_mouse_exited() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property($TextureRect, "scale", Vector2(1.0, 1.0), 0.2)
#endregion

#region Employee Checks
func _on_employee_detection_area_entered(area: Area2D) -> void:
	if area.get_parent() is Employee:
		
		if area.get_parent().blocked == true:
			return
		
		target_employee = area.get_parent()
		
		# Make it smaller effect
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property($TextureRect, "scale", Vector2(.2, .2), 0.2)
		
		SignalBus.apply_employee_preview_effects.emit(self, area.get_parent())
		

func _on_employee_detection_area_exited(area: Area2D) -> void:
	if area.get_parent() is Employee:
		
		if area.get_parent().blocked == true:
			return
		
		target_employee = null
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property($TextureRect, "scale", Vector2(1, 1), 0.2)
		
		SignalBus.remove_employee_preview_effects.emit(self, area.get_parent())
#endregion
