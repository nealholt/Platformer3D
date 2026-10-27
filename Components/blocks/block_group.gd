extends Node3D
# Preconditions:
#     All children of this group should be rigid bodies.
#     Level.minimum_height should be in scope.
# Postconditions:
#     This class periodically despawns its rigid body
#     children if they fall below Level.minimum_height

@onready var timer:Timer = $Timer

@export var min_refresh_time:float = 1.0 ## seconds
@export var max_refresh_time:float = 20.0 ## seconds


func despawn_outofbounds_blocks() -> void:
	var block_count:int = get_child_count()
	#print('=== Checking and despawning blocks ===')
	#print('Current block count: ', block_count)
	
	# Restart timer. Wait max time if there are currently no blocks
	if block_count == 0:
		timer.start(max_refresh_time)
		return
	else:
		timer.start(randf_range(min_refresh_time, max_refresh_time))
	
	# Despawn out of bounds blocks
	var block:RigidBody3D
	for node:Node in get_children():
		if !(node is RigidBody3D): continue # skip the timer child
		block = node as RigidBody3D
		if block.global_position.y < Level.minimum_height:
			#print('  Despawning 1 block')
			block.queue_free.call_deferred()
