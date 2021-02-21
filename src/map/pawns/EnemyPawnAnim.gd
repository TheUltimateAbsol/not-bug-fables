extends PawnAnim

class_name EnemyPawnAnim

enum {STANDARD, PLAYER_HIT, ENEMY_HIT}
signal encountered(type)
onready var hitbox = $Root/Hitbox

#This script is suject to change across different enemies
#This isn't final
#Though every single enemy is going to need a hitbox, I guess you could
#standardize that...
#Maybe even use a remote transform 2d if it needs to move with a sprite...

func _on_area_entered(area:Area2D):
	if (area.is_in_group("player_attack")):
		emit_signal("encountered", PLAYER_HIT)
	elif (area.is_in_group("player_hitbox")):
		#TODO
		#Add custom code here to send ENEMY_HIT based on attack sequence
		emit_signal("encountered", STANDARD)
	
