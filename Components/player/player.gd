class_name Player extends CharacterBody3D

# This is a very simple tutorial that starts off WAY too basic
# for you, but could be good for students.
# Complete Playlist:
# https://www.youtube.com/playlist?list=PLda3VoSoc_TTp8Ng3C57spnNkOw3Hm_35

# However, the blender content did teach me new things:
# Lesson 7: Making a coin in Blender:
# https://www.youtube.com/watch?v=bYM9gs-iqkQ
# Lesson 8: At 18:45 here there's an adjustment to the
# material that was brought over from Blender
# https://www.youtube.com/watch?v=kzdbaI9vZ5g

# I made many of my own changes

# Note that while sprint feels better on shift, I put it on
# both/either control or left mouse, because shift and w
# causes "Keyboard Ghosting" which in this case prevented
# jumping while sprinting and moving forward and also
# prevented exiting from the game while sprinting and moving
# forward.
# Keyboard Ghosting is a HARDWARE issue, that is not easily (or at all?)
# fixable without simply remapping your key bindings.

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var armature: Node3D = $Armature
@onready var ray_cast: RayCast3D = $RayCast3D
@onready var camera_control: Node3D = $CameraControl
@onready var player_reset_system: Node = $PlayerResetSystem
@onready var state_machine: StateMachine = $StateMachine

@onready var impact_particles: GPUParticles3D = $ImpactParticles
@onready var sprint_particles: GPUParticles3D = $SprintParticles

@export var lives :int = 3
@export var walk_speed :float = 4.0
@export var walk_acceleration :float = 15.0
@export var sprint_speed :float = 9.0
@export var sprint_acceleration :float = 20.0
@export var deceleration :float = 15.0
@export var jump_velocity :float = 8.0
# Hold jump longer to jump higher. Release early to jump shorter.
@export_range(0,1) var decelerate_on_jump_release :float = 0.5
# Magnifier for gravity on the way down for a snappier jump feel
@export var fall_gravity_mult :float = 1.3 ## Percent
# Multiplier to magnify jump_velocity when sprinting
@export var sprint_jump_mult :float = 1.5 ## Percent
# Minimum speed needed in order to apply sprint_jump_mult
@export var sprint_jump_min_speed :float = 1.0
# coyote_time is time after which player steps off the ground that
# the player can still jump. gravity still applies immediately.
@export var coyote_time :float = 0.15 ## Seconds
# Time after stepping off the ground before gravity kicks in
@export var sky_walk_time :float = 0.0 ## Seconds
# How many extra jumps you can do in the air after jumping from
# the ground or stepping off a ledge.
@export var double_jump_limit :int = 1
# Force applied to rigid bodies player collides with
@export var collision_force :float = 1.0
# If player can alter velocity in mid air.
@export var can_move_in_air :bool = true
@export var can_rotate_camera :bool = true
@export var can_move_left_right :bool = true
@export var can_sprint :bool = true
@export var can_push_blocks :bool = false

@export var camera_pos :Vector3 = Vector3(0.0, 2.16, 4.17) ## Camera position
@export var camera_rot_deg :Vector3 = Vector3(-20.0, 0.0, 0.0) ## Camera rotation in degrees

var gravity :float = ProjectSettings.get_setting('physics/3d/default_gravity')

# How fast camera lerps to player's position
var camera_lerp_str :float = 6.0
# How fast character model aligns to sloped floors
var floor_align_lerp_str :float = 20.0
# Used for aligning character model to floor
#var xform :Transform3D # No longer used, but keep for now.
# Remember the heading independently of armature rotation
var heading: Vector3 = Vector3.FORWARD

# Player state variables
var move_dir :Vector2 = Vector2.ZERO
var sprinting:bool = false
var just_jumped:bool = false
var is_moving:bool = false
var has_minimal_velocity:bool = false
var was_on_floor:bool = true # true if previous frame was on floor
var on_floor:bool = false
# How many extra jumps can be performed while in the air
var double_jumps_remaining:int
# Fall speed at the end of the most recent fall. Will be positive.
# Will be the magnitude in the downward direction.
var previous_fall_speed:float = 0.0
var sky_walk_remaining :float = 0.0 ## Seconds
# Used by the "bounceZone" so that skywalk doesn't trigger
# when the player gets bounced
var suppress_next_skywalk :bool = false


func _ready() -> void:
	state_machine.transitioned.connect(on_state_transition)
	animation_player.play('idle')
	set_camera_control.call_deferred(can_rotate_camera)


func _physics_process(delta: float) -> void:
	# Handle all other inputs. You don't want to escape to main
	# menu and then run physics_process. If you try, you will
	# get errors.
	input_management()
	
	# Get the rest of the player's state:
	update_player_state()
	
	apply_gravity(delta)
	
	# Execute behaviors relevant to state
	state_machine.update(delta)
	
	move_and_slide()
	
	# This should be called after move_and_slide()
	handle_rigid_body_collisions()
	
	# Make camera controller match player's position
	camera_control.position = lerp(camera_control.position, position, delta*camera_lerp_str)
	
	# If we fall below level, game over
	if global_position.y < Level.minimum_height:
		SoundManager.play(SoundManager.SFX.DEATH_BY_FALL)
		die()


func input_management() -> void:
	# Get the movement direction and sprint/jump status.
	move_dir = Input.get_vector("left", "right", "forward", "backward")
	sprinting = can_sprint and Input.is_action_pressed('sprint')
	just_jumped = Input.is_action_just_pressed('jump') and 0.0 < jump_velocity
	if !can_move_left_right:
		move_dir.x = 0.0
	# If jump was released and character is still on the way up
	# decelerate by a factor.
	# It feels like holding jump makes you jump higher, which
	# is what we want.
	if Input.is_action_just_released('jump') and 0 < velocity.y:
		velocity.y *= decelerate_on_jump_release


func update_player_state() -> void:
	# True if the player is inputting movement
	is_moving = move_dir != Vector2.ZERO
	# Adjust sprinting. Previously sprinting is true if sprint key
	# is down, but you also need to be moving to sprint.
	sprinting = sprinting and is_moving
	# True if there is any velocity (or there WILL BE velocity)
	has_minimal_velocity = is_moving or 1.0 < velocity.length_squared()
	# Floor status
	var now_on_floor :bool = is_on_floor()
	was_on_floor = on_floor and !now_on_floor
	on_floor = now_on_floor
	if on_floor:
		double_jumps_remaining = double_jump_limit

func move(delta:float, temp_speed:float, temp_accel:float) -> void:
	# Move in direction camera is facing
	if is_moving:
		# Rotate character in direction camera is facing
		armature.rotation.y = camera_control.get_rotation_y() - move_dir.angle() - PI/2.0
		# Change velocity
		var forward: Vector3 = camera_control.get_facing()
		var right: Vector3 = Vector3.UP.cross(forward)
		var direction: Vector3 = -(right * move_dir.x + forward * move_dir.y).normalized()
		# move_and_slide internally handles the frame time when moving
		# the CharacterBody3D, so you don't multiply temp_speed by delta
		# on next two lines
		# https://www.reddit.com/r/godot/comments/18gx6tc/trying_to_understand_when_to_use_delta_with_a/
		velocity.x = move_toward(velocity.x, direction.x * temp_speed, temp_accel * delta)
		velocity.z = move_toward(velocity.z, direction.z * temp_speed, temp_accel * delta)
	else: # Decelerate down to zero
		decelerate(delta)


func decelerate(delta:float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
	velocity.z = move_toward(velocity.z, 0.0, deceleration * delta)


func jump() -> void:
	# Jump higher if sprinting (assuming there's any significant
	# velocity as well). There will be no velocity if running
	# into a wall, even if the sprint key is held.
	if sprinting and \
	(sprint_jump_min_speed < abs(velocity.z) or \
	sprint_jump_min_speed < abs(velocity.x)):
		velocity.y = jump_velocity * sprint_jump_mult
	else:
		velocity.y = jump_velocity
	# Play sound and randomize pitch
	SoundManager.play(SoundManager.SFX.JUMP, -0.15, 0.0)

# Enemy calls bounce. It's like jump, but witohut the noise
func bounce() -> void:
	velocity.y = jump_velocity


func apply_gravity(delta:float) -> void:
	# Ignore gravity while on the floor
	if on_floor: return
	# Count down sky_walk_time
	sky_walk_remaining -= delta
	# Check if sky walk is still in effect
	if 0.0 < sky_walk_remaining: return
	# Apply gravity. More gravity when falling for a
	# snappier feel.
	if velocity.y < 0.0:
		velocity.y -= gravity * delta * fall_gravity_mult
	else:
		velocity.y -= gravity * delta


# This function was a super duper pain in the ass and I don't
# deeply understand it. It's also only cosmetically adjusting
# the angle of the player model so it's not really very
# important. An earlier version is commented out below, but that
# version was introducing accumulated twist in the model when
# turning the camera, running on uneven surfaces, and moving at
# a diagonal.
func align_with_floor(floor_normal: Vector3, delta: float) -> void:
	if floor_normal.is_zero_approx():
		return
	# Get lerp weight. It's used twice below, so I thought a variable
	# was appropriate to use
	var lerp_weight:float = clampf(floor_align_lerp_str*delta, 0.0, 1.0)
	# Gradually rotate the body's up direction toward the floor
	# normal, so that abrupt changes in the floor normal don't cause
	# sudden tilting.
	var current_up: Vector3 = global_basis.y.normalized()
	# Previously this was a slerp rather than a lerp, but no matter
	# how many normalized vectors I threw at it, it would give me
	# an occasional error about un-normalized vectors. I think the
	# error occurred during sky walk, but changing to lerp cleared
	# up the error.
	var smoothed_up: Vector3 = current_up.lerp(
		floor_normal.normalized(),
		lerp_weight
	)
	if smoothed_up.is_zero_approx():
		return
	smoothed_up = smoothed_up.normalized()
	
	# Get the body's current forward direction.
	# Old way
	#var forward:Vector3 = -global_basis.z
	# New, hopefully more robust, way START
	# Project the heading onto the floor plane.
	var forward: Vector3 = heading.slide(smoothed_up)
	# Keep the previous heading if the projection is degenerate.
	if forward.is_zero_approx():
		return
	# Otherwise update the heading
	forward = forward.normalized()
	heading = forward
	# New, hopefully more robust, way END
	
	# Project the forward direction onto the floor plane.
	# This removes the component pointing into or away from the floor,
	# keeping the character's heading aligned with the floor's surface.
	forward = forward.slide(smoothed_up)
	
	# If the projected direction is nearly zero, it cannot define a
	# reliable forward direction. Return early.
	if forward.is_zero_approx():
		return
	forward = forward.normalized()
	
	# Calculate the right direction from the cross product of
	# forward and up.
	var right: Vector3 = forward.cross(smoothed_up).normalized()
	
	# Recalculate forward to ensure all three directions are perpendicular.
	var corrected_forward: Vector3 = smoothed_up.cross(right).normalized()
	
	# Construct the target basis from the right, up, and backward directions.
	# Basis expects its Z axis to point backward, so negate forward.
	var target_basis: Basis = Basis(right, smoothed_up, -corrected_forward)
	
	# Gradually rotate the body's current orientation toward the target.
	# Clamping the interpolation weight between 0 and 1.
	global_basis = global_basis.slerp(
		target_basis,
		lerp_weight
	).orthonormalized()
# Old version that begins accumulating twist
# in the model in rare circumstances
#func align_with_floor(floor_normal:Vector3, delta:float) -> void:
	#xform = global_transform
	#xform.basis.y = floor_normal
	#xform.basis.x = -xform.basis.z.cross(floor_normal)
	#xform.basis = xform.basis.orthonormalized()
	#global_basis = global_basis.slerp(xform.basis, floor_align_lerp_str * delta)


func on_state_transition(old_state_name:String, new_state_name:String) -> void:
	#print(new_state_name.to_lower())
	
	# Play animation
	animation_player.play(new_state_name.to_lower())
	
	# Consider emitting sprint particles
	sprint_particles.emitting = new_state_name == 'Run'
	
	# Check for impact particles when we land on ground
	if old_state_name=='Fall' and new_state_name!='Jump':
		#print(previous_fall_speed)
		# Set particle count based on fall speed
		var particle_count:int = int(2*previous_fall_speed)
		# Minimum of 3 particles in order to emit at all
		if 3 < particle_count:
			# Emit particles:
			impact_particles.emitting = true
			# Set speed based on fall speed
			impact_particles.process_material.set('initial_velocity', Vector2(previous_fall_speed,previous_fall_speed)/2.0)
			# Set particle count based on fall speed
			impact_particles.amount = particle_count
		# Play audio. Scale volume with fall speed, max zero
		SoundManager.play_volume(SoundManager.SFX.LANDING, min(0.0, -20.0 + previous_fall_speed))
	
	#match new_state_name:
		#'Idle':
			#animation_player.play('idle')
		#'Fall':
			#animation_player.play('fall')
		#'Jump':
			#animation_player.play('jump')
		#'Run':
			#animation_player.play('run')
		#'Walk':
			#animation_player.play('walk')


func set_camera_control(can_rotate:bool) -> void:
	can_rotate_camera = can_rotate
	camera_control.can_rotate_camera = can_rotate
	
	camera_control.set_pos_rot_deg(camera_pos, camera_rot_deg)


# This is called when the player falls out of the level or
# is hit by an enemy.
func die() -> void:
	lives -= 1
	if 0 <= lives:
		Events.player_died.emit(lives)
		# Restore earlier state
		player_reset_system.restore()
	else:
		# Go to game over menu
		MainMenu.main_menu.load_lose_menu()


func reset_sky_walk() -> void:
	if suppress_next_skywalk:
		suppress_next_skywalk = false
		return
	# reset skywalk time
	sky_walk_remaining = sky_walk_time


func set_can_rotate_camera(tf:bool) -> void:
	can_rotate_camera = tf
	set_camera_control.call_deferred(can_rotate_camera)


# Any rigid bodies that collide with the player and aren't
# already colliding with FootArea will be shoved away from
# the player.
# It might be nice to add:
# - Only apply impulse when player is moving
# - Only apply impulse when player velocity is in the direction
#   of the colliding RigidBody3D
# Or maybe the whole player should be remade as a RigidBody3D
# if you really want fancy physics.
func handle_rigid_body_collisions() -> void:
	if !can_push_blocks: return
	# Collisions with blocks
	# Initial code from here: https://forum.godotengine.org/t/simple-characterbody-and-rigidbody-interaction/103874
	# See foot_area.gd for more details.
	for i:int in get_slide_collision_count():
		var collision:KinematicCollision3D = get_slide_collision(i)
		var collider:Object = collision.get_collider()
		# Only apply impulse to rigid bodies that are not in
		# the no_impulse group. "no_impulse" is applied by
		# the FootArea and allows the player to stand on Ridid
		# bodies.
		if collider is RigidBody3D and not collider.is_in_group('no_impulse'):
			collider.apply_central_impulse(-collision.get_normal() * collision_force)
