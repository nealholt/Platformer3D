class_name IdleState extends State

func _ready() -> void:
	state_name = "Idle"

# stuff that gets applied every frame while in this state
func update(delta : float) -> void:
	if !play_char.on_floor:
		# Immediately remove remaining sky walk
		# because it's funny, like the coyote realizing
		# it's not on the ground before falling.
		play_char.sky_walk_remaining = 0.0
		transitioned.emit(self, "FallState")
	elif play_char.just_jumped:
		transitioned.emit(self, "JumpState")
	elif play_char.is_moving:
		if play_char.sprinting:
			transitioned.emit(self, "RunState")
		else:
			transitioned.emit(self, "WalkState")
	move(delta)

func move(delta : float) -> void:
	# Rotate character to align with the floor.
	# The has_minimal_velocity condition prevents updating unless moving,
	# which we want because too frequent updating on the edge
	# between a ramp and a flat block can cause icky oscillation.
	# However, this extra condition makes the character not update
	# when landing on a ramp after jumping.
	# Previously I used this condition...
	#if play_char.on_floor and play_char.is_moving:
	# ...but the has_minimal_velocity condition here works better.
	if play_char.on_floor and play_char.has_minimal_velocity:
		play_char.align_with_floor(play_char.ray_cast.get_collision_normal(), delta)
	
	play_char.decelerate(delta)
