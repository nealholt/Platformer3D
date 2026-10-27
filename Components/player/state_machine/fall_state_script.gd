class_name FallState extends State

func _ready() -> void:
	state_name = "Fall"

func enter(char_reference : CharacterBody3D) -> void:
	super.enter(char_reference)
	# Reset fall speed
	play_char.previous_fall_speed = 0.0

func update(delta : float) -> void:
	if play_char.on_floor:
		if !play_char.has_minimal_velocity and !play_char.is_moving:
			transitioned.emit(self, "IdleState")
		else:
			if play_char.sprinting:
				transitioned.emit(self, "RunState")
			else:
				transitioned.emit(self, "WalkState")
	elif play_char.just_jumped and 0 < play_char.double_jumps_remaining:
		play_char.jump()
		play_char.double_jumps_remaining -= 1
	else:
		# Update player fall speed to whichever is more bigger,
		# current fall speed or current negated y velocity.
		play_char.previous_fall_speed = maxf(-play_char.velocity.y, play_char.previous_fall_speed)
	move(delta)

func move(delta : float) -> void:
	# Rotate character to align straight up.
	play_char.align_with_floor(Vector3.UP, delta)
	
	if !play_char.can_move_in_air: return
	
	# Move in direction camera is facing
	# Determine speed and acceleration
	var temp_speed:float = play_char.walk_speed
	var temp_accel:float = play_char.walk_acceleration
	if play_char.sprinting:
		temp_speed = play_char.sprint_speed
		temp_accel = play_char.sprint_acceleration
	play_char.move(delta,temp_speed, temp_accel)
