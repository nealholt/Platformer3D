extends Control

# These are used only on title menu
@export var play_button:Button
@export var level_buttons:Array[Button]
@export var reset_high_scores:Button
# These are used only on win screen:
@export var time_background:ColorRect
@export var time_label:Label

var fullscreen:bool = true

func _ready() -> void:
	# Release the mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Don't show next level button on the last level
	if Global.is_last_level and has_node('ButtonNextLevel'):
		$ButtonNextLevel.visible = false
	# Play music
	SoundManager.stop_level_music()
	if !SoundManager.menu_music_is_playing():
		SoundManager.play_menu_music()
	# Set display to fullscreen. When I tried to set
	# fullscreen as the default in project settings,
	# the toggle button was broken, but this way it works.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	# If there's a time container, display time in it.
	# This should ONLY happen on the win screen.
	if time_label:
		time_label.text = 'Your time:\n'+Global.get_elapsed_time_string(Global.level_completion_time)
		var is_best:bool = SaveSpeed.update_level_time(Global.level_number, Global.level_completion_time)
		if is_best:
			time_label.text += '\nNew best!'
			time_background.size.y = 250 # resize
		else:
			var best:float = SaveSpeed.get_level_time(Global.level_number)
			time_label.text += '\nBest time:\n'+Global.get_elapsed_time_string(best)
	# The following should only happen on the title menu.
	# Show buttons depending on how many levels have been beaten.
	if play_button:
		var completed_levels:int = SaveSpeed.get_completed_levels()
		if 0 < completed_levels:
			# Hide the play button. Not needed since the level
			# buttons will be visible.
			play_button.visible = false
			# Allow resetting of high scores
			reset_high_scores.visible = true
			# Plus 1 so we can go to the next level
			for i:int in completed_levels+1:
				level_buttons[i].visible = true

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

# Under Project Settings -> Display -> Window
# Set Mode to "Exclusive Fullscreen"
# Set Borderless on
func _on_toggle_fullscreen_pressed() -> void:
	fullscreen = !fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _load_level(level_number:int) -> void:
	SoundManager.stop_menu_music()
	SoundManager.play_button_sound()
	get_tree().change_scene_to_file("res://Levels/level_"+str(level_number)+".tscn")

func _load_main_menu() -> void:
	SoundManager.play_button_sound()
	get_tree().change_scene_to_file("res://UI/menu_title.tscn")

func _replay_most_recent_level() -> void:
	_load_level(Global.most_recently_played)

func _play_next_level() -> void:
	_load_level(Global.most_recently_played+1)

func _on_reset_progress_pressed() -> void:
	SaveSpeed.reset_best_times()
	get_tree().reload_current_scene.call_deferred()

func _close_game() -> void:
	get_tree().quit()
