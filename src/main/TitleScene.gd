extends Control

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

func skip():
	$IntroPlayer.seek(2.9)
	
func start():
	print("start")
