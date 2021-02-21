extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	print("body entered ", body)


func _on_Area2D_area_entered(area):
	print("area entered ", area)
	


func _on_Area2D_area_shape_entered(area_id, area, area_shape, self_shape):
	print("area shape entered ", area_id, area, area_shape, self_shape)
	
	

func _on_Area2D_body_shape_entered(body_id, body, body_shape, area_shape):
	print("body shape entered ", body_id, body, body_shape, area_shape)
