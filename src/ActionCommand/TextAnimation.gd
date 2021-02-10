extends Node

onready var anim = $TextAnim

func hide_all():
	for child in get_children():
		if child is Node2D:
			child.hide()
			
func reposition():
	

func _ready():
	hide_all()

func good():
	hide_all()
	$Good.show()
	$RemoveTimer.start()

func oof():
	hide_all()
	$Fail.show()
	$RemoveTimer.start()
	
