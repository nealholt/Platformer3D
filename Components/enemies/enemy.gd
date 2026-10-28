extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ray: RayCast3D = $RayCast3D
@onready var sides_checker: Area3D = $SidesChecker
@onready var top_checker: Area3D = $TopChecker

@export var direction:Vector3 = Vector3.ZERO
@export var turns_at_edges:bool = true ## Turn off for units that you want to walk down stairs
@export var motionless:bool = false ## Turn on for units that you don't want to move

var speed :float = 2.0
var gravity :float = ProjectSettings.get_setting('physics/3d/default_gravity')
var turning:bool = false
var turn_duration:float = 0.6 # Seconds

func _ready() -> void:
	if motionless:
		set_physics_process(false)

func _physics_process(delta: float) -> void:
	# move_and_slide internally handles the frame time when moving
	# the CharacterBody3D, so you don't multiply the next two lines
	# by delta
	# https://www.reddit.com/r/godot/comments/18gx6tc/trying_to_understand_when_to_use_delta_with_a/
	velocity.x = speed * direction.x
	velocity.z = speed * direction.z
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	if is_on_wall() and !turning:
		turn_around()
	
	# Turn around at a cliff edge, but to prevent spinning in
	# place, don't trigger this again if already turning
	if turns_at_edges and !turning and is_on_floor() and !ray.is_colliding():
		turn_around()


func turn_around() -> void:
	# Original source: https://www.youtube.com/watch?v=gJUi4D__3vo
	# Enter the turning state
	turning = true
	# Backup direction
	var backup_direction:Vector3 = direction
	# Don't move while rotating
	direction = Vector3.ZERO
	# Rotate
	var turn_tween:Tween = create_tween()
	turn_tween.tween_property(self, 'rotation_degrees', Vector3(0,180,0), turn_duration).as_relative()
	await turn_tween.finished
	# Continue moving in opposite direction
	direction = -backup_direction
	# Exit the turning state
	turning = false


func _on_sides_checker_body_entered(body: Node3D) -> void:
	SoundManager.play(SoundManager.SFX.DEATH_BY_ENEMY)
	# If we struck the player, call player's die function
	if body is Player:
		body.die()


func _on_top_checker_body_entered(body: Node3D) -> void:
	# If squashed by player, reset player's fall speed to zero.
	if body is Player:
		body.previous_fall_speed = 0.0
	animation_player.play('squash', -0.1, 0.1)
	SoundManager.play(SoundManager.SFX.ENEMY_SQUASH)
	body.bounce()
	sides_checker.set_collision_mask_value(1, false)
	top_checker.set_collision_mask_value(1, false)
	# Stop moving
	set_physics_process(false)
	# Check for coin production
	if Global.enemies_drop_coins:
		# Adjust coins up slightly so they don't spawn in ground.
		var pos:Vector3 = global_position + Vector3.UP*0.5
		Coin.new_coin(pos)
	# Delete self after 1 second
	await get_tree().create_timer(1.0).timeout
	queue_free.call_deferred()
