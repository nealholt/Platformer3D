class_name PlayerResetSysyem extends Node

# Backup player information every time the timer goes off.
# Restore player to earlier state when they die.

# Assume parent of this node is the player
@onready var player : Player = $".."

const BACKUP_COUNT :int = 10

var index :int = 0
var global_pos_arr : Array[Vector3]
var rotation_arr : Array[Vector3]
var velocity_arr : Array[Vector3]

func _ready() -> void:
	_initial_fill.call_deferred()

# Fill the whole array with current position
# so there's no weird bad values in the array.
func _initial_fill() -> void:
	for i:int in BACKUP_COUNT:
		global_pos_arr.push_back(player.global_position)
		rotation_arr.push_back(player.rotation)
		velocity_arr.push_back(player.velocity)

func _on_timer_timeout() -> void:
	# Save player info
	global_pos_arr[index] = player.global_position
	rotation_arr[index] = player.rotation
	velocity_arr[index] = player.velocity
	index = get_next_index()

func restore() -> void:
	player.global_position = global_pos_arr[get_next_index()]
	player.rotation = rotation_arr[get_next_index()]
	player.velocity = velocity_arr[get_next_index()]
	# Fill up array with copies of this position otherwise
	# player can wait 5 sec, die again, and then be 5 sec
	# further along in the level, or worst case be
	# plummetting to their death over a chasm again.
	for i:int in BACKUP_COUNT:
		global_pos_arr[i] = player.global_position
		rotation_arr[i] = player.rotation
		velocity_arr[i] = player.velocity

func get_next_index() -> int:
	return (index+1) % BACKUP_COUNT
