extends Node2D

signal finished

func _ready():
	$Particles2D.emitting = true
	$Particles2D2.emitting = true
	$MapHit.play()
	$Timer.start()
	


func _on_Timer_timeout():
	emit_signal("finished")
