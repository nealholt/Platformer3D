extends AnimatableBody3D

# This platform moves back and forth between begin and end
@export var pos_begin :Vector3 = Vector3.ZERO
@export var pos_end :Vector3 = Vector3.ZERO
@export var move_duration :float = 2.0
@export var end_point_delay :float = 0.7 # Pause at end point

var move_tween :Tween = null

func _ready() -> void:
	move()

func move() -> void:
	if move_tween and move_tween.is_running():
		move_tween.kill()
	move_tween = create_tween().set_loops()
	move_tween.tween_property(self, "position", pos_end, move_duration)
	move_tween.tween_interval(end_point_delay)
	move_tween.tween_property(self, "position", pos_begin, move_duration)
	move_tween.tween_interval(end_point_delay)
