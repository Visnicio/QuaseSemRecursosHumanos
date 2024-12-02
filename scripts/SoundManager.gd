extends Node

signal music_changed

var bg_music_player: AudioStreamPlayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	bg_music_player = AudioStreamPlayer.new()
	bg_music_player.bus = "music"
	add_child(bg_music_player)
	randomize()


func play_sound(sound_path: String, bus_name: String) -> AudioStreamPlayer:
	var audio_player = AudioStreamPlayer.new() as AudioStreamPlayer
	audio_player.bus = bus_name
	audio_player.stream = load(sound_path)
	audio_player.pitch_scale = randf_range(0.98, 1.02)
	add_child(audio_player)
	audio_player.play()
	audio_player.finished.connect(destroy_audio_player.bind(audio_player))
	return audio_player

func destroy_audio_player(audio_player: AudioStreamPlayer) -> void:
	if is_instance_valid(audio_player):
		audio_player.queue_free()


func set_bg_music(sound_path: String, override: bool) -> void:
	
	if bg_music_player.stream != null and bg_music_player.stream.resource_path == sound_path:
		return
	
	if override or !bg_music_player.playing:
		bg_music_player.stream = load(sound_path)
		bg_music_player.play()
		var tween = create_tween()
		bg_music_player.volume_db = -100
		tween.tween_property(bg_music_player, "volume_db", 0, 2)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.set_ease(Tween.EASE_IN)
