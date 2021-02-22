extends Control

const confirmation = preload("res://src/ActionCommand/257227__javierzumer__ui-interface-positive.wav")
const game = "res://src/main/Game.tscn"

var can_skip = true

func _unhandled_input(event: InputEvent) -> void:
	#We don't care about echos because they provide no new data
	if event is InputEventKey:
		if event.is_action_pressed("ui_accept"):
			if can_skip:
				skip()
			else:
				start()

func disable_skip():
	can_skip = false
	$Music.play(2.1)

func skip():
	$IntroPlayer.seek(4)
	$SFX.volume_db = -80
	
func start():
	set_process(false)
	$SFX.volume_db = 10
	$SFX.stream = confirmation
	$SFX.play()
	fade_out($Music)
	$IntroPlayer.play("Exit")
	yield($IntroPlayer, "animation_finished")
	get_tree().change_scene(game)
	
	
	
	
	
onready var tween_out = get_node("Tween")
export var transition_duration = 0.5
export var transition_type = 1 # TRANS_SINE

func fade_out(stream_player):
	# tween music volume down to 0
	tween_out.interpolate_property(stream_player, "volume_db", 0, -80, transition_duration, transition_type, Tween.EASE_IN, 0)
	tween_out.start()
	# when the tween ends, the music will be stopped

func _on_TweenOut_tween_completed(object, key):
	# stop the music -- otherwise it continues to run at silent volume
	object.stop()
