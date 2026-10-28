class_name Level extends Node3D

# Level-specific parameters
@export var this_level:int = 1
@export var game_over_height:float = -15.0
@export var coins_to_win:int = 1
@export var help:HelpText # Unset on all but level 0

@onready var coin_group: Node3D = $Coins
@onready var hud: HUD = $HUD

# Make this static so all new coins can reference it
static var coin_node: Node3D

# Since timers count down until a stopping point, I figured
# it made sense to simply track level time so far in a float
# and increase it in _process
# The code for elapsed_time is duplicated in WedgeWars
var elapsed_time :float = 0.0

# Go to game over screen if player falls below this height.
# May be different on different levels.
static var minimum_height:float

# How many coins are needed to win the current level
static var num_coins_to_win:int


func _ready() -> void:
	#print(coin_group.get_child_count())
	Events.picked_coin.connect(check_win)
	coin_node = coin_group
	Global.most_recently_played = this_level
	# coin threshold to win
	num_coins_to_win = coins_to_win
	# minimum height
	minimum_height = game_over_height
	# Reset count of picked up coins back to zero
	Global.coins = 0
	# Reset enemies to NOT drop coins
	Global.enemies_drop_coins = false
	# Play music
	# TODO TESTING SoundManager.play.call_deferred(SoundManager.SFX.LEVEL_MUSIC)
	# Only for tutorials:
	if help:
		help._display_help_text.call_deferred('ws keys or forward/back\n arrow keys to move')
	# Reset level completion time
	Global.level_completion_time = 0.0
	Global.level_number = this_level


# Update and display elapsed level time
func _process(delta: float) -> void:
	elapsed_time += delta
	hud.update_timer_label(Global.get_elapsed_time_string(elapsed_time))


# Check the level's win condition. This is triggered by coins
# emitting the picked_coin signal.
func check_win() -> void:
	# Check win condition
	if Global.coins >= Level.num_coins_to_win:
		# Set level completion time
		Global.level_completion_time = elapsed_time
		Global.level_number = this_level
		# Go to win screen
		MainMenu.main_menu.load_win_menu()
