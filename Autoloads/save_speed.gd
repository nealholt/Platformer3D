extends Node

# Save player's level times to and from file.
# https://docs.godotengine.org/en/stable/classes/class_fileaccess.html

const SAVE_PATH: String = "user://level_times.save"
@export var level_count: int = 3

# Stores the best time in seconds for each level.
var level_times: Array[float] = []

func _ready() -> void:
	# Initialize every level with -1.0
	level_times.resize(level_count)
	level_times.fill(-1.0)
	load_times()
	#for time:float in level_times:
		#print(time)

func get_level_time(level_index:int) -> float:
	# Ignore invalid level indices and negative times.
	if level_index < 0 or level_index >= level_count:
		return 0.0
	else:
		return level_times[level_index]

# Returns true if this is a new best time
func update_level_time(level_index:int, new_time:float) -> bool:
	# Ignore invalid level indices and negative times.
	if level_index < 0 or level_index >= level_count or new_time < 0.0:
		return false
	# Save only if this is the first time or a faster time.
	if level_times[level_index] < 0.0 or new_time < level_times[level_index]:
		level_times[level_index] = new_time
		save_times()
		return true
	return false

func save_times() -> void:
	# Write each level's time to file
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not save level times: " + error_string(FileAccess.get_open_error()))
		return
	for time:float in level_times:
		file.store_float(time)
	file.close()

func load_times() -> void:
	# Keep default values if the save file doesn't exist.
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not load level times: " + error_string(FileAccess.get_open_error()))
		return
	# Read out values
	for i:int in range(level_count):
		# Check if enough data remains in the file to read
		# another float. (Floats occupy 4 bytes, hence the 4.)
		# This is a safeguard against a truncated or otherwise
		# corrupted save file.
		if file.get_position() + 4 > file.get_length():
			break
		level_times[i] = file.get_float()
	file.close()

# This effectively erases all the best times
func reset_best_times() -> void:
	level_times.resize(level_count)
	level_times.fill(-1.0)
	save_times()

# Returns index of highest level completed
func get_completed_levels() -> int:
	for i:int in level_count:
		if level_times[i] < 0.0:
			return i
	return level_count-1
