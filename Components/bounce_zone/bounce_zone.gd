extends Area3D

func _on_body_entered(body:Node3D) -> void:
	if 'velocity' in body:
		body.velocity.y = 30.0
		body.suppress_next_skywalk = true
		SoundManager.play_whoosh_sound()
