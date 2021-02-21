extends Position2D

class_name PawnAnim
#Note: AnimationPlayer will be different for each node
#If we make it a node standard with the scene, it will share assets every time
#May be worthwhile making something different for a playable character vs enemy

#In the meanwhile, let's just stick all of our code here and only call what's necessary
	
func flip(direction:Vector2):
	if direction.x >0:
		$Root.scale = Vector2(1, 1)
	elif direction.x < 0:
		$Root.scale = Vector2(-1,1)
	else:
		pass #Don't change direction if you don't need to
	
func walk(direction:Vector2):
	flip(direction)
	$CharacterAnimation.play("Walk")

#no need to flip, prior action will generate flip anyways
func stand():
	$CharacterAnimation.play("Idle")
	
#no need to flip, prior action will generate flip anyways
func attack():
	$CharacterAnimation.play("Attack")
	yield($CharacterAnimation, "animation_finished")
	stand()
