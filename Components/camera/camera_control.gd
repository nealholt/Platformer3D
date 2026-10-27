class_name CameraControl extends Node3D

# Move mouse to rotate camera around player

@export var rotation_speed :float = 0.002
@export var lower_rot_lim: float = deg_to_rad(20.0)
@export var upper_rot_lim: float = deg_to_rad(50.0)
@export var can_rotate_camera :bool = true

@onready var camera_pivot: Node3D = $Pivot
@onready var camera_3d: Camera3D = $Pivot/Camera3D

func _ready() -> void:
	# Hide the mouse and lock it in the screen
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event:InputEvent) -> void:
	if !(event is InputEventMouseMotion): return
	if !can_rotate_camera: return
	# Rotate y
	camera_pivot.rotation.y -= event.relative.x * rotation_speed
	# Rotate x
	camera_pivot.rotation.x -= event.relative.y * rotation_speed
	camera_pivot.rotation.x = clampf(
		camera_pivot.rotation.x,
		-upper_rot_lim,
		lower_rot_lim
	)

# Used to move player
func get_facing() -> Vector3:
	var forward: Vector3 = -camera_pivot.global_transform.basis.z
	# Remove vertical component so that there's no vertical velocity
	# imparted by the camera.
	forward.y = 0.0
	return forward.normalized()

# Used to orient player
func get_rotation_y() -> float:
	return camera_pivot.rotation.y

# Set position and rotation in degrees
func set_pos_rot_deg(pos:Vector3, rot_deg:Vector3) -> void:
	camera_3d.position = pos
	camera_3d.rotation_degrees = rot_deg
