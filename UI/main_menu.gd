class_name MainMenu extends Node

# Static self reference.
# Now any script can reference the main_scene like so:
# MainMenu.main_menu
# BE WARNED: This will not work correctly if there is more
# than one MainScene in a scene.
static var main_menu:MainMenu = null

@onready var main_3d: Node3D = $Main3D

@onready var menu_title: Control = $MenuTitle
@onready var menu_game_win: Control = $MenuGameWin
@onready var menu_game_over: Control = $MenuGameOver

# These are used only on title menu
@onready var play_button:Button = $MenuTitle/VBoxContainer/PlayButton
@onready var level_buttons:Array[Button] = [
	$MenuTitle/VBoxContainer/Level0Button,
	$MenuTitle/VBoxContainer/Level1Button,
	$MenuTitle/VBoxContainer/Level2Button
]
@onready var reset_high_scores:Button = $MenuTitle/VBoxContainer/ResetProgress

# These are used only on win screen:
@onready var time_background:ColorRect = $MenuGameWin/ColorRect2
@onready var time_label:Label = $MenuGameWin/TimeContainer/Label
@onready var button_next_level: Button = $MenuGameWin/ButtonNextLevel

var fullscreen:bool = true


func _ready() -> void:
	# Make this scene statically accessible
	if main_menu:
		push_error('ERROR: Unique static MainMenu reference has already been set. This should only ever get set once.')
	main_menu = self
	
	# Set display to fullscreen. When I tried to set
	# fullscreen as the default in project settings,
	# the toggle button was broken, but this way it works.
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	_load_main_menu()


func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			# Escape from main menu exits the game
			# Escape from within level exits to main menu
			if menu_title.visible:
				get_tree().quit()
			else:
				load_main_menu_button()

# Under Project Settings -> Display -> Window
# Set Mode to "Exclusive Fullscreen"
# Set Borderless on
func _on_toggle_fullscreen_pressed() -> void:
	fullscreen = !fullscreen
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _hide_menus() -> void:
	menu_title.visible = false
	menu_game_win.visible = false
	menu_game_over.visible = false

func _load_menu_generic() -> void:
	unload_level()
	_hide_menus()
	# Release the mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Play music
	SoundManager.stop(SoundManager.SFX.LEVEL_MUSIC)
	if !SoundManager.is_playing(SoundManager.SFX.MENU_MUSIC):
		SoundManager.play(SoundManager.SFX.MENU_MUSIC)

func load_main_menu_button() -> void:
	SoundManager.play(SoundManager.SFX.BUTTON_PRESS)
	_load_main_menu()

func _load_main_menu() -> void:
	_load_menu_generic()
	menu_title.visible = true
	# Show buttons depending on how many levels have been beaten.
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

func load_win_menu() -> void:
	_load_menu_generic()
	menu_game_win.visible = true
	# Display time
	time_label.text = 'Your time:\n'+Global.get_elapsed_time_string(Global.level_completion_time)
	var is_best:bool = SaveSpeed.update_level_time(Global.level_number, Global.level_completion_time)
	if is_best:
		time_label.text += '\nNew best!'
		time_background.size.y = 250 # resize
	else:
		var best:float = SaveSpeed.get_level_time(Global.level_number)
		time_label.text += '\nBest time:\n'+Global.get_elapsed_time_string(best)
	# Level 2 is the last level so only display next level button
	# if there is a next level
	button_next_level.visible = Global.level_number < 2


func load_lose_menu() -> void:
	_load_menu_generic()
	menu_game_over.visible = true

func _replay_most_recent_level() -> void:
	_load_level(Global.most_recently_played)

func _play_next_level() -> void:
	_load_level(Global.most_recently_played+1)

func _on_reset_progress_pressed() -> void:
	SaveSpeed.reset_best_times()
	get_tree().reload_current_scene.call_deferred()

func _close_game() -> void:
	get_tree().quit()

func unload_level() -> void:
	# Queue free every child of main_3d
	for c:Node in main_3d.get_children():
		c.queue_free()

func _load_level(level_number:int) -> void:
	SoundManager.stop(SoundManager.SFX.MENU_MUSIC)
	SoundManager.play(SoundManager.SFX.BUTTON_PRESS)
	unload_level()
	_hide_menus()
	var level_path :String = "res://Levels/level_%d.tscn" % level_number
	SceneLoader.load_scene(level_path)
	await SceneLoader.load_finished
	var level_resource :PackedScene = SceneLoader.get_loaded_scene()
	# Instantiate loaded level
	var level_instance: Node = level_resource.instantiate()
	# Attach level as child of main
	main_3d.add_child(level_instance)
