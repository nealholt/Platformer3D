extends Control

@onready var sound_enemy: AudioStreamPlayer = $SoundEnemy
@onready var sound_coin: AudioStreamPlayer = $SoundCoin
@onready var sound_fall: AudioStreamPlayer = $SoundFall
@onready var sound_button: AudioStreamPlayer = $SoundButton
@onready var sound_upgrade: AudioStreamPlayer = $SoundUpgrade
@onready var sound_whoosh: AudioStreamPlayer = $SoundWhoosh

@onready var music_menu: AudioStreamPlayer = $MusicMenu
@onready var music_level: AudioStreamPlayer = $MusicLevel

func _ready() -> void:
	play_menu_music()

func play_enemy_sound() -> void:
	sound_enemy.play()

func play_coin_sound() -> void:
	sound_coin.play()

func play_fall_sound() -> void:
	sound_fall.play()

func play_button_sound() -> void:
	sound_button.play()

func play_upgrade_sound() -> void:
	sound_upgrade.play()

func play_whoosh_sound() -> void:
	sound_whoosh.play()

func play_menu_music() -> void:
	music_menu.play()

func stop_menu_music() -> void:
	music_menu.stop()

func menu_music_is_playing() -> bool:
	return music_menu.playing

func play_level_music() -> void:
	music_level.play()

func stop_level_music() -> void:
	music_level.stop()

func level_music_is_playing() -> bool:
	return music_level.playing
