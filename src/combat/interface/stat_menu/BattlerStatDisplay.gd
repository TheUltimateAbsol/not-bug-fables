extends TextureRect

const LEAFCUTTER = preload("res://assets/sprites/ui/Leafcutter.png")
const GHOST = preload("res://assets/sprites/ui/Ghost Ant.png")

var active:bool = false
var battler:Battler

func initialize(battler: Battler):
	active = true
	self.battler = battler
	$HP.initialize(battler, StatBarNumeric.HEALTH)
	$AP.initialize(battler, StatBarNumeric.AP)
	
	#TODO
	#Here's a hack until the proper battle symbols come in
	match battler.display_name:
		"Leafcutter": texture = LEAFCUTTER
		"Ghost": texture = GHOST

