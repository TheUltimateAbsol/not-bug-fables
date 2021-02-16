extends Position2D

class_name BattlerAnim

export(NodePath) var battler_node
onready var battler:Battler = get_node(battler_node)
var target:Battler
onready var anim = $AnimationPlayer
onready var extents: RectExtents = $RectExtents

const MIDDLE = Vector2(966, 663)

func _ready():
	$AttackPlayer.play("Reset")

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

func _chain_anim_track_backwards(after:Animation, before:Animation, node_path:NodePath):
	_set_last_key_value(before, node_path, _get_key_value(after, node_path, 0))

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
		
func _adjust_all_keys_backwards(anim:Animation, node_path:NodePath, base_value):
	var num_keys = anim.track_get_key_count(anim.find_track(node_path))
	var old_values = []; old_values.resize(num_keys)
	var new_values = []; new_values.resize(num_keys)
	for i in range(num_keys):
		old_values[i] = _get_key_value(anim, node_path, i)
	new_values[num_keys-1] = base_value
	for i in range(num_keys-2, -1, -1):
		new_values[i] = old_values[i] - old_values[num_keys-1] + base_value
	for i in range(num_keys):
		_set_key_value(anim, node_path, i, new_values[i])
		
func _curve_adjust_all(curve:Curve2D, base_value:Vector2):
	var num_points = curve.get_point_count()
	var old_values = []
	var new_values = []
	for i in range(num_points):
		old_values.push_back(curve.get_point_position(i))
	new_values.push_back(base_value)
	for i in range(1, num_points):
		new_values.push_back(old_values[i] - old_values[0] + base_value)
	for i in range(num_points):
		curve.set_point_position(i, new_values[i])

#TODO: separate this out into different classses in the future 
#so each character has their own anim file
	

	
func play_shoot(target:Battler, actor:Battler):
	#set target position
	var target_position = to_local(target.target_global_position) + Vector2(-140, 0)
	var target_middle_x = (to_local(actor.position).x + target_position.x)/2
	$ArrowShoot.curve.set_point_position(1, Vector2(target_middle_x, $ArrowShoot.curve.get_point_position(1).y - $ArrowShoot.curve.get_point_position(0).y ))
	$ArrowShoot.curve.set_point_position(2, target_position)
	$ArrowFail.curve.set_point_position(1, Vector2(target_middle_x, $ArrowFail.curve.get_point_position(1).y))
	$ArrowFail.curve.set_point_position(2, target_position)
	_curve_adjust_all($ArrowFail2.curve, target_position)
	#play
	$AttackPlayer.play("Shoot_Windup")
	yield($AttackPlayer, "attack_ended")
	if $AttackPlayer.input_received == true:
		$AttackPlayer.play("Shoot_Success")
		yield($AttackPlayer, "animation_finished")
		var hit = Hit.new(actor.stats.strength)
		target.take_damage(hit)
		$AttackPlayer.play("Shoot_Success_Hit")
		yield($AttackPlayer, "animation_finished")
	else:
		$AttackPlayer.play("Shoot_Fail")
		yield($AttackPlayer, "animation_finished")
		var hit = Hit.new(actor.stats.strength/2)
		target.take_damage(hit)
		$AttackPlayer.play("Shoot_Fail2")
		yield($AttackPlayer, "animation_finished")
	

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

	
func play_slice(target:Battler, actor:Battler):
	var target_position = to_local(target.skin.battler_anim.global_position) + Vector2(-140, 0)
	#Set target positions, then work backwards
	
	#Ending target positions
	_adjust_all_keys($AttackPlayer.get_animation("Slice_Fail"), ".:position", target_position)
	_set_last_key_value($AttackPlayer.get_animation("Slice_Fail"), ".:position", Vector2(0,0))
	_adjust_all_keys($AttackPlayer.get_animation("Slice_Success"), ".:position", target_position)
	_set_last_key_value($AttackPlayer.get_animation("Slice_Success"), ".:position", Vector2(0,0))
	#work backwards
	_adjust_all_keys_backwards($AttackPlayer.get_animation("Slice_Attack"), ".:position", target_position)
	_chain_anim_track_backwards($AttackPlayer.get_animation("Slice_Attack"), $AttackPlayer.get_animation("Slice_Approach"), ".:position")

	$AttackPlayer.play("Slice_Approach")
	yield($AttackPlayer, "animation_finished")
	$AttackPlayer.play("Slice_Attack")
	yield($AttackPlayer, "attack_ended")
	if $AttackPlayer.input_received == true:
		var hit = Hit.new(actor.stats.strength)
		target.take_damage(hit)
		$AttackPlayer.play("Slice_Success")
		print("hi")
	else:
		var hit = Hit.new(actor.stats.strength*0.5)
		target.take_damage(hit)
		$AttackPlayer.play("Slice_Fail")
	yield($AttackPlayer, "animation_finished")
	
func block():
	$CharacterAnimation.play("Block")
	
func hurt():
	$CharacterAnimation.play("Hurt")
