class_name JumpState extends State

func _ready() -> void:
	state_name = "Jump"


func enter(play_char_ref : CharacterBody3D) -> void:
	super.enter(play_char_ref)
	play_char.jump()
	# Immediately remove any remaining sky walk
	play_char.sky_walk_remaining = 0.0


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
	elif play_char.velocity.y < 0.0:
		transitioned.emit(self, "FallState")
	
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
