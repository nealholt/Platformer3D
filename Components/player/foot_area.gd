extends Area3D

# This script allows player to stand on rigid bodies without
# applying an impulse to them on every frame (which looks
# jittery and can cause jank) 
# Inspired by this
# https://forum.godotengine.org/t/simple-characterbody-and-rigidbody-interaction/103874

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.add_to_group('no_impulse')

func _on_body_exited(body: Node3D) -> void:
	if body is RigidBody3D:
		body.remove_from_group('no_impulse')
