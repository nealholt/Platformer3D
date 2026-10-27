class_name UpgradeResource extends Resource

enum UPGRADE_TYPE {JUMP_ENABLED, SPRINT_ENABLED, DOUBLE_JUMP_PLUS,
WALK_SPEED_PLUS, ENEMIES_DROP_COINS, SKYWALK_PLUS,
SIDE_TO_SIDE_ENABLED, AIR_MOVE_ENABLED, CAMERA_ROTATE_ENABLED,
JUMP_PLUS, CAN_PUSH_BLOCKS}

@export var upgrade_type:UPGRADE_TYPE = UPGRADE_TYPE.JUMP_ENABLED
@export var amount:float = 1.0
@export var help_text:String = 'CHANGE ME\nin upgrade_resource'
# Aesthetics:
@export var image:Texture2D
@export var text:String
@export var color:Color


func apply_upgrade(p:Player) -> void:
	match upgrade_type:
		UPGRADE_TYPE.JUMP_ENABLED:
			p.jump_velocity = amount
		UPGRADE_TYPE.SPRINT_ENABLED:
			p.can_sprint = true
		UPGRADE_TYPE.DOUBLE_JUMP_PLUS:
			p.double_jump_limit += int(amount)
		UPGRADE_TYPE.WALK_SPEED_PLUS:
			p.walk_speed += amount
		UPGRADE_TYPE.ENEMIES_DROP_COINS:
			Global.enemies_drop_coins = true
		UPGRADE_TYPE.SKYWALK_PLUS:
			p.sky_walk_time += amount
		UPGRADE_TYPE.SIDE_TO_SIDE_ENABLED:
			p.can_move_left_right = true
		UPGRADE_TYPE.AIR_MOVE_ENABLED:
			p.can_move_in_air = true
		UPGRADE_TYPE.CAMERA_ROTATE_ENABLED:
			p.set_can_rotate_camera(true)
		UPGRADE_TYPE.JUMP_PLUS:
			p.jump_velocity += amount
		UPGRADE_TYPE.CAN_PUSH_BLOCKS:
			p.can_push_blocks = true
