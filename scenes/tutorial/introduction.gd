extends Control

@onready var dialog: Label = $DialogPanel/Dialog
@onready var speaker: TextureRect = $Speaker

enum State {
	TALKING,
	DONE
}

var speechs: Array[String] = [
	"Olá chefe. Esse é seu primeiro dia como gerente da equipe 5 na Krupra Zopertado Inc. Nós estamos com um projeto pra entregar no final da proxima semana e você precisa gerenciar a nova equipe.",
	"A produtividade da equipe esta em suas mãos, mas cuidado pra nao deixar ninguém com burnout... Já tivemos problemas demais com isso por aqui.",
	"Seu trabalho é atribuir atividades para seus funcionários, então fique de olho na produtividade (🔵) e como essa atividade pode estressar o funcionario (🔴)",
	"Se o estresse de algum funcionario chegar no limite, podemos ter consequências.",
	"Ao final de cada dia a equipe fará entregas e veremos o progresso do projeto.",
	"Boa sorte chefe."
]

var murns: Array[String] = [
	"res://assets/sfx/murn1.wav",
	"res://assets/sfx/murn2.wav",
	"res://assets/sfx/murn3.wav",
	"res://assets/sfx/murn4.wav",
	"res://assets/sfx/murn5.wav",
	"res://assets/sfx/murn3.wav",
]

var speech_index: int = 0
var current_state: State = State.TALKING
@export var speed: float

func _ready() -> void:
	if GameManager.played_tutorial:
		queue_free()
		return
	switch_text()


func _process(delta: float) -> void:
	
	if current_state == State.TALKING:
		dialog.visible_ratio += delta * speed
		
		if Input.is_action_just_pressed("click"):
			current_state = State.DONE
		pass
		
		if dialog.visible_ratio == 1:
			current_state = State.DONE
	elif current_state == State.DONE:
		dialog.visible_ratio = 1
		if Input.is_action_just_pressed("click"):
			if speech_index >= speechs.size():
				GameManager.played_tutorial = true
				visible = false
			
			speech_index += 1
			switch_text()
		pass
	
	
	pass

func switch_text() -> void:
	if speech_index >= speechs.size():
		return
	current_state = State.TALKING
	dialog.visible_ratio = 0
	dialog.text = speechs[speech_index]
	SoundManager.play_sound(murns[speech_index], "sfx")
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(speaker, "rotation_degrees", 0, .2).from(-15)
	tween.parallel().tween_property(speaker, "scale", Vector2(1.1,1.1), .2).from(Vector2(.6,.6))
	tween.parallel().tween_property(speaker, "scale", Vector2(1,1), .2).from(Vector2(.6,.6))
