extends Position2D

class_name BattlerAnim

export(NodePath) var battler_node
onready var battler:Battler = get_node(battler_node)
var target:Battler
onready var anim = $AnimationPlayer
onready var extents: RectExtents = $RectExtents

func play_stagger():
	anim.play("take_damage")
	yield(anim, "animation_finished")

func play_death():
	anim.play("death")
	yield(anim, "animation_finished")


#TODO: separate this out into different classses in the future 
#so each character has their own anim file
func play_jump(target):
	$AttackPlayer.attacker = battler
	$AttackPlayer.target = target
	
	#set target position
	var target_position = to_local(target.target_global_position)
	var anim = $AttackPlayer.get_animation("Jump")

	anim.track_set_key_value(anim.find_track(".:position"), 1, target_position)
	anim.track_set_key_value(anim.find_track(".:position"), 2, target_position)
	
	$AttackPlayer.play("Jump");
	yield($AttackPlayer, "attack_ended")
	
	
func play_shoot(target):
	$AttackPlayer.attacker = battler
	$AttackPlayer.target = target
	
	#set target position
	var target_position = to_local(target.target_global_position)
	var anim = $AttackPlayer.get_animation("Shoot")
	var track_idx = anim.find_track("arrow:position:x")
	var front = anim.bezier_track_get_key_value(track_idx, anim.track_get_key_count(track_idx) - 1)
	var back = anim.bezier_track_get_key_value(track_idx, anim.track_get_key_count(track_idx) - 3)
	var mid = (front+back)/2
	anim.bezier_track_set_key_value(track_idx, anim.track_get_key_count(track_idx) - 1, target_position.x)
	anim.bezier_track_set_key_value(track_idx, anim.track_get_key_count(track_idx) - 2, mid)
	
	$AttackPlayer.play("Shoot");
	yield($AttackPlayer, "attack_ended")


func play_ram(target:Battler):
	$AttackPlayer.attacker = battler
	$AttackPlayer.target = target
	
	var target_position = to_local(target.target_global_position)
	#code to set approach positions
	var approach_target = target_position + Vector2(400, 0)
	var approach_anim = $AttackPlayer.get_animation("Ram_Approach")
	var track_idx = approach_anim.find_track(".:position")
	approach_anim.track_set_key_value(track_idx, approach_anim.track_get_key_count(track_idx) - 1, approach_target)
	#code to set tackle positions
	var lunge_anim = $AttackPlayer.get_animation("Ram_Lunge")
	track_idx = lunge_anim.find_track(".:position")
	for i in range(1, lunge_anim.track_get_key_count(track_idx)):
		lunge_anim.track_set_key_value(track_idx, i, target_position + lunge_anim.track_get_key_value(track_idx, i) - lunge_anim.track_get_key_value(track_idx, i-1))
	lunge_anim.track_set_key_value(track_idx, 0, target_position)
	lunge_anim.track_set_key_value(track_idx, lunge_anim.track_get_key_count(track_idx) - 1, target_position)
	#code to set reset positions
	var reset_anim = $AttackPlayer.get_animation("Ram_Reset")
	track_idx = reset_anim.find_track(".:position")
	reset_anim.track_set_key_value(track_idx, 0, target_position)
			
	$AttackPlayer.play("Ram_Approach")
	yield($AttackPlayer, "animation_finished")
	$AttackPlayer.play("Ram_Lunge")
	yield($AttackPlayer, "animation_finished")
	if $AttackPlayer.block_received == true:
		$AttackPlayer.damage(0.5)
		target.skin.battler_anim.block()
	$AttackPlayer.play("Ram_Reset")
	yield($AttackPlayer, "animation_finished")
	
func block():
	$CharacterAnimation.play("Block")
