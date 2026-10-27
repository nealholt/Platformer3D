class_name HelpText extends Node2D
# Class for tutorializing the upgrades

@onready var label: Label = $HelpLayer/MarginContainer/Label
@onready var help_timer: Timer = $HelpTimer


func _ready() -> void:
	Events.picked_upgrade.connect(_display_help_text)


func _on_help_timer_timeout() -> void:
	label.visible = false


func _display_help_text(text:String) -> void:
	# \n was showing as plain text rather than
	# newline when I did it this way:
	#label.text = text
	# But this makes \n newline for some reason.
	# Source: https://www.reddit.com/r/godot/comments/ajvnfd/labels_localization_and_line_breaks/
	label.text = tr(text).c_unescape()
	
	label.visible = true
	help_timer.start()
