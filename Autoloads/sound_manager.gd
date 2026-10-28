extends Control

# The following enums must match the sound effect children
# of the sound manager root node and be in the same order.
enum SFX {
	DEATH_BY_ENEMY,
	GAIN_COIN,
	DEATH_BY_FALL,
	BUTTON_PRESS,
	GAIN_UPGRADE,
	WHOOSH,
	MENU_MUSIC,
	LEVEL_MUSIC,
	LANDING,
	JUMP,
	ENEMY_SQUASH
}

var all_sounds:Array[AudioStreamPlayer]

func _ready() -> void:
	# Load all the audio streams into the array
	for asp:AudioStreamPlayer in get_children():
		all_sounds.push_back(asp)

# Play at a particular volume. This WILL permanently
# alter the volume of this sound effect!
func play_volume(sfx:SFX, vol:float) -> void:
	all_sounds[sfx].volume_db = vol
	all_sounds[sfx].play()

func play(sfx:SFX) -> void:
	all_sounds[sfx].play()

func stop(sfx:SFX) -> void:
	all_sounds[sfx].stop()

func is_playing(sfx:SFX) -> bool:
	return all_sounds[sfx].playing
