extends Position2D

class_name BattlerAnim

export(NodePath) var battler_node
onready var battler:Battler = get_node(battler_node)
var target:Battler
onready var anim = $AnimationPlayer
onready var extents: RectExtents = $RectExtents

const MIDDLE = Vector2(966, 663)

func play_stagger():
	anim.play("take_damage")
	yield(anim, "animation_finished")

func play_death():
	anim.play("death")
	yield(anim, "animation_finished")

func _get_key_value(anim:Animation, node_path:NodePath, key:int):
	var track_idx = anim.find_track(node_path)
	var track_get_type = anim.track_get_type(track_idx)
	match track_get_type:
		Animation.TYPE_VALUE: return anim.track_get_key_value(track_idx, key)
		Animation.TYPE_BEZIER:  return anim.bezier_track_get_key_value(track_idx, key)

func _get_key_value_from_end(anim:Animation, node_path:NodePath, distance_from_end:int):
	var track_idx = anim.find_track(node_path)
	var new_key = anim.track_get_key_count(track_idx) - 1 - distance_from_end
	return _get_key_value(anim, node_path, new_key)

func _set_key_value(anim:Animation, node_path:NodePath, key:int, value):
	var track_idx = anim.find_track(node_path)
	var track_get_type = anim.track_get_type(track_idx)
	match track_get_type:
		Animation.TYPE_VALUE: anim.track_set_key_value(track_idx, key, value)
		Animation.TYPE_BEZIER:  anim.bezier_track_set_key_value(track_idx, key, value)

func _set_key_value_from_end(anim:Animation, node_path:NodePath, distance_from_end:int, value):
	var track_idx = anim.find_track(node_path)
	var new_key = anim.track_get_key_count(track_idx) - 1 - distance_from_end
	_set_key_value(anim, node_path, new_key, value)

func _set_last_key_value(anim:Animation, node_path:NodePath, value):
	_set_key_value_from_end(anim, node_path, 0, value)

func _set_first_key_value(anim:Animation, node_path:NodePath, value):
	_set_key_value(anim, node_path, 0, value)

func _chain_anim_track(before:Animation, after:Animation, node_path:NodePath):
	_set_first_key_value(after, node_path, _get_key_value_from_end(before, node_path, 0))

func _adjust_all_keys(anim:Animation, node_path:NodePath, base_value):
	var num_keys = anim.track_get_key_count(anim.find_track(node_path))
	var old_values = []
	var new_values = []
	for i in range(num_keys):
		old_values.push_back(_get_key_value(anim, node_path, i))
	new_values.push_back(base_value)
	for i in range(1, num_keys):
		new_values.push_back(old_values[i] - old_values[0] + base_value)
	for i in range(num_keys):
		_set_key_value(anim, node_path, i, new_values[i])

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


func play_lunge(target:Battler, actor:Battler):
	var target_position = to_local(target.skin.battler_anim.global_position) + Vector2(30, 0)
	var middle_position = to_local(MIDDLE)
	var windup_target = target_position.direction_to(middle_position)*100 + middle_position
	#code to set approach positions
	_set_last_key_value($AttackPlayer.get_animation("Ram_Approach"), ".:position", middle_position)
	#code to set windup position
	_adjust_all_keys($AttackPlayer.get_animation("Ram_Windup"), ".:position", middle_position)
	_set_key_value_from_end($AttackPlayer.get_animation("Ram_Windup"), ".:position", 1, windup_target)
	_set_key_value_from_end($AttackPlayer.get_animation("Ram_Windup"), ".:position", 0, windup_target)
	#code to set tackle positions
	_chain_anim_track($AttackPlayer.get_animation("Ram_Windup"), $AttackPlayer.get_animation("Ram_Lunge"), ".:position")
	_set_last_key_value($AttackPlayer.get_animation("Ram_Lunge"), ".:position", target_position)
	#code to set reset positions
	_chain_anim_track($AttackPlayer.get_animation("Ram_Lunge"), $AttackPlayer.get_animation("Ram_Reset"), ".:position")

	$AttackPlayer.play("Ram_Approach")
	yield($AttackPlayer, "animation_finished")
	$AttackPlayer.play("Ram_Windup")
	yield($AttackPlayer, "animation_finished")
	$AttackPlayer.play("Ram_Lunge")
	yield($AttackPlayer, "animation_finished")
	if $AttackPlayer.block_received == true:
		var hit = Hit.new(actor.stats.strength*0.5)
		target.take_damage(hit)
		target.skin.battler_anim.block()
	else:
		var hit = Hit.new(actor.stats.strength)
		target.take_damage(hit)
		target.skin.battler_anim.hurt()
	$AttackPlayer.play("Ram_Reset")
	yield($AttackPlayer, "animation_finished")
	

func play_chomp(target:Battler, actor:Battler):
	var target_position = to_local(target.skin.battler_anim.global_position) + Vector2(140, 0)
	#code to set approach positions
	_set_last_key_value($AttackPlayer.get_animation("Chomp_Approach"), ".:position", target_position)
	#code to set attack position
	_adjust_all_keys($AttackPlayer.get_animation("Chomp_Attack"), ".:position", target_position)
	#code to set reset positions
	_chain_anim_track($AttackPlayer.get_animation("Chomp_Attack"), $AttackPlayer.get_animation("Chomp_Reset"), ".:position")

	$AttackPlayer.play("Chomp_Approach")
	yield($AttackPlayer, "animation_finished")
	$AttackPlayer.play("Chomp_Attack")
	yield($AttackPlayer, "animation_finished")
	if $AttackPlayer.block_received == true:
		var hit = Hit.new(actor.stats.strength*0.5)
		target.take_damage(hit)
		target.skin.battler_anim.block()
	else:
		var hit = Hit.new(actor.stats.strength)
		target.take_damage(hit)
		target.skin.battler_anim.hurt()
	$AttackPlayer.play("Chomp_Reset")
	yield($AttackPlayer, "animation_finished")
	
func block():
	$CharacterAnimation.play("Block")
	
func hurt():
	$CharacterAnimation.play("Hurt")
