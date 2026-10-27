extends Node

# Emitted when a coin is picked up
@warning_ignore("unused_signal") # Added so the debugger stops nagging me.
signal picked_coin

# Emitted when an upgrade is acquired
@warning_ignore("unused_signal") # Added so the debugger stops nagging me.
signal picked_upgrade(help_text:String)

# Emitted when player dies
@warning_ignore("unused_signal") # Added so the debugger stops nagging me.
signal player_died(lives_remaining:int)
