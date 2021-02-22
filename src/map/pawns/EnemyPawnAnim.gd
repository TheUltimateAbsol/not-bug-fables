extends PawnAnim

class_name EnemyPawnAnim

signal encountered(type)
onready var hitbox = $Root/Hitbox

#This script is suject to change across different enemies
#This isn't final
#Though every single enemy is going to need a hitbox, I guess you could
#standardize that...
#Maybe even use a remote transform 2d if it needs to move with a sprite...

func _on_area_entered(area:Area2D):
	if (area.is_in_group("player_attack")):
		emit_signal("encountered", Globals.BATTLE_OPENING_TYPES.PLAYER_HIT)
	elif (area.is_in_group("player_hitbox")):
		#TODO
		#Add custom code here to send ENEMY_HIT based on attack sequence
		emit_signal("encountered", Globals.BATTLE_OPENING_TYPES.STANDARD)
	
func play_alert():
	$AnimationPlayer.play("Alert")
	yield($AnimationPlayer, "animation_finished")
	
func play_walk():
	$AnimationPlayer.play("Walk")
	
func play_idle():
	$AnimationPlayer.play("Idle")

func flip(direction:Vector2):
	direction = direction.normalized()
	if direction.x >0.1:
		$Root.scale = Vector2(1, 1)
	elif direction.x < -0.1:
		$Root.scale = Vector2(-1,1)
	else:
		pass #Don't change direction if you don't need to
	
