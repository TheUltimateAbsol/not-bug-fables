extends Control


func initialize(type):
	match(type):
		Globals.MESSAGE_TYPES.GOOD:
			$Label.text = "Good"
			$Label.modulate = Color("#caff89")
		Globals.MESSAGE_TYPES.MISS:
			$Label.text = "Miss..."
			$Label.modulate = Color("#808080")
		Globals.MESSAGE_TYPES.BLOCK:
			$Label.text = "Block!"
			$Label.modulate = Color("#729fff")

func play():
	$AnimationPlayer.play("Appear")
