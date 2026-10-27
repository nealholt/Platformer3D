class_name HUD extends CanvasLayer

@onready var coins_label: Label = $CoinsLabel
@onready var timer_label: Label = $TimerLabel

@onready var lives:Array[TextureRect] = [$Life1, $Life2, $Life3]

func _ready() -> void:
	Events.picked_coin.connect(update_label)
	Events.player_died.connect(lose_life)
	Global.coins = 0
	# Defer this call so that the level has a chance to load in
	# numbed of coins needed to win.
	update_label.call_deferred()

func update_label() -> void:
	coins_label.text = str(Global.coins)+'/'+str(Level.num_coins_to_win)

func update_timer_label(t:String) -> void:
	timer_label.text = t

func lose_life(lives_remaining:int) -> void:
	var max_lives:int = lives.size()
	for i:int in (max_lives - lives_remaining):
		lives[max_lives-i-1].modulate = Color.DIM_GRAY
