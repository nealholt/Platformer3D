class_name Coin extends Area3D

@onready var animation: AnimationPlayer = $AnimationPlayer

const ROT_SPEED :float = 100.0 # rotation speed


static func new_coin(pos:Vector3) -> Coin:
	# I was getting weird errors when coins were spawned from
	# killed enemies, a pair of errors:
	# Failed to instantiate scene state of "", node count is 0. Make sure the PackedScene resource is valid.
	# and
	# Required object "rp_child" is null.
	# The only info I could find online was this
	# https://forum.godotengine.org/t/failed-to-instantiate-scene-state-of-snake-body-tscn-node-count-is-0-make-sure-the-packedscene-resource-is-valid/70264
	# where the person changed from preload to load, so
	# that's what I did and it seems to have fixed the issue.
	var coin_scene:PackedScene = load("res://Components/coins/coin.tscn")
	var c:Coin = coin_scene.instantiate() 
	Level.coin_node.add_child(c)
	c.global_position = pos
	return c

func _process(delta: float) -> void:
	rotate_y(deg_to_rad(delta * ROT_SPEED))

func _on_body_entered(_body: Node3D) -> void:
	# Play sound and randomize pitch
	SoundManager.play(SoundManager.SFX.GAIN_COIN, -0.2, 0.0)
	print('coin body entered') # TODO TESTING
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
