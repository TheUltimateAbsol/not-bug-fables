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
