extends Area3D

@export var upgrade:UpgradeResource

func _ready() -> void:
	$Sprite3D.texture = upgrade.image
	$Sprite3D.modulate = upgrade.color
	$Label3D.text = upgrade.text
	$Label3D.modulate = upgrade.color


func _on_body_entered(body:Node3D) -> void:
	if !is_instance_valid(upgrade) or !(body is Player):
		return
	upgrade.apply_upgrade(body)
	Events.picked_upgrade.emit(upgrade.help_text)
	# Play audio
	# TODO TESTING SoundManager.play(SoundManager.SFX.GAIN_UPGRADE)
	# Turn off collisions to prevent double collision
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	# Delete self
	queue_free.call_deferred()
