extends Area3D

@export var upgrade:UpgradeResource

func _ready() -> void:
	$Sprite3D.texture = upgrade.image
	$Sprite3D.modulate = upgrade.color
	$Label3D.text = upgrade.text
	$Label3D.modulate = upgrade.color


func _on_body_entered(body:Node3D) -> void:
	if upgrade and body is Player:
		upgrade.apply_upgrade(body)
		Events.picked_upgrade.emit(upgrade.help_text)
	# Play audio
	SoundManager.play_upgrade_sound()
	# Turn off collisions to prevent double collision
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	# Delete self
	queue_free.call_deferred()
