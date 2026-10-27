class_name WalkState extends State

# Coyote time remaining before transitioning to falling state
var coyote_remaining :float = 0.0

func _ready() -> void:
	state_name = "Walk"

func update(delta : float) -> void:
	# Player stepped off of the floor, reset skywalk
	if !play_char.on_floor and play_char.was_on_floor:
		play_char.reset_sky_walk()
	
	if play_char.just_jumped:
		transitioned.emit(self, "JumpState")
	elif !play_char.on_floor and play_char.sky_walk_remaining <= 0.0:
		# If the player WAS on the floor, reset coyote time
		if play_char.was_on_floor:
			coyote_remaining = play_char.coyote_time
		else:
			coyote_remaining -= delta
		# Only fall after coyote time has elapsed
		if coyote_remaining <= 0.0:
			transitioned.emit(self, "FallState")
	elif play_char.sprinting:
		transitioned.emit(self, "RunState")
	elif !play_char.has_minimal_velocity and !play_char.is_moving:
		transitioned.emit(self, "IdleState")
	
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
	
	play_char.move(delta, play_char.walk_speed, play_char.walk_acceleration)
