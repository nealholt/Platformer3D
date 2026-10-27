@abstract
class_name State extends Node

# it's normal if this signal isn't used in this script,
# because it's purpose is to be used in the scripts that
# extends from the State class
@warning_ignore("unused_signal") # Added so the debugger stops nagging me.
signal transitioned(state : State, new_state_name : String)

var state_name : String
var play_char : CharacterBody3D

func enter(char_reference : CharacterBody3D) -> void:
	play_char = char_reference

func exit() -> void:
	pass #exit state

@abstract func update(delta : float) -> void

@abstract func move(delta : float) -> void
