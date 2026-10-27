class_name Coin extends Area3D

const COIN_SCENE:PackedScene = preload("res://Components/coins/coin.tscn")

@onready var animation: AnimationPlayer = $AnimationPlayer

const ROT_SPEED :float = 100.0 # rotation speed


static func new_coin(pos:Vector3) -> Coin:
	var c:Coin = COIN_SCENE.instantiate()
	Level.coin_node.add_child(c)
	c.global_position = pos
	return c

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(delta * ROT_SPEED))

func _on_body_entered(_body: Node3D) -> void:
	SoundManager.play_coin_sound()
	Global.coins += 1
	# Signal
	Events.picked_coin.emit()
	# Turn off collisions to prevent double pickup of coin
	set_collision_layer_value(3, false)
	set_collision_mask_value(1, false)
	# Animate then queue free
	animation.play("bounce")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
