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
func play_volume(sfx:SFX, vol:float, rand_pitch_min:float=0.0, rand_pitch_max:float=0.0) -> void:
	# Randomize pitch or reset pitch to 1.0
	if rand_pitch_min==0.0 and rand_pitch_max==0.0:
		all_sounds[sfx].pitch_scale = 1.0
	else:
		all_sounds[sfx].pitch_scale = 1.0 + randf_range(rand_pitch_min, rand_pitch_max)
	# Change volume
	all_sounds[sfx].volume_db = vol
	# Play sound
	all_sounds[sfx].play()

func play(sfx:SFX, rand_pitch_min:float=0.0, rand_pitch_max:float=0.0) -> void:
	# Randomize pitch or reset pitch to 1.0
	if rand_pitch_min==0.0 and rand_pitch_max==0.0:
		all_sounds[sfx].pitch_scale = 1.0
	else:
		all_sounds[sfx].pitch_scale = 1.0 + randf_range(rand_pitch_min, rand_pitch_max)
	# Play sound
	all_sounds[sfx].play()

func stop(sfx:SFX) -> void:
	all_sounds[sfx].stop()

func is_playing(sfx:SFX) -> bool:
	return all_sounds[sfx].playing
