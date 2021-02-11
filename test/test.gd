extends Node2D

signal sig

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func response():
	print("hello world")

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("sig", self, "response", [], CONNECT_ONESHOT)
	emit_signal("sig")
	emit_signal("sig")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
