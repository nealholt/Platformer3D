extends Node

# How many coins have been collected
var coins :int = 0

# Whether or not enemies drop coins
var enemies_drop_coins:bool = false

# Track most recently played level in order to replay
# and to transition to next level
var most_recently_played : int

var is_last_level:bool = false

var level_completion_time :float ##seconds
var level_number :int


func get_elapsed_time_string(elapsed_time:float) -> String:
	var minutes:int = int(elapsed_time/60)
	# Pad minutes with a zero
	var opt_zero_min: String = '0' if minutes < 10 else ''
	var seconds:int = int(elapsed_time)%60
	# Pad seconds with a zero
	var opt_zero_sec: String = '0' if seconds < 10 else ''
	return opt_zero_min+str(minutes)+':'+opt_zero_sec+str(seconds)
