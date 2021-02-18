extends Position2D

class_name BattlerAnim

export(NodePath) var battler_node
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
	AnimFunc.curve_adjust_all($ArrowFail2.curve, target_position)
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
	AnimFunc.set_last_key_value($AttackPlayer.get_animation("Ram_Approach"), ".:position", middle_position)
	#code to set windup position
	AnimFunc.adjust_all_keys($AttackPlayer.get_animation("Ram_Windup"), ".:position", middle_position)
	AnimFunc.set_key_value_from_end($AttackPlayer.get_animation("Ram_Windup"), ".:position", 1, windup_target)
	AnimFunc.set_key_value_from_end($AttackPlayer.get_animation("Ram_Windup"), ".:position", 0, windup_target)
	#code to set tackle positions
	AnimFunc.chain_anim_track($AttackPlayer.get_animation("Ram_Windup"), $AttackPlayer.get_animation("Ram_Lunge"), ".:position")
	AnimFunc.set_last_key_value($AttackPlayer.get_animation("Ram_Lunge"), ".:position", target_position)
	#code to set reset positions
	AnimFunc.chain_anim_track($AttackPlayer.get_animation("Ram_Lunge"), $AttackPlayer.get_animation("Ram_Reset"), ".:position")

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
	AnimFunc.set_last_key_value($AttackPlayer.get_animation("Chomp_Approach"), ".:position", target_position)
	#code to set attack position
	AnimFunc.adjust_all_keys($AttackPlayer.get_animation("Chomp_Attack"), ".:position", target_position)
	#code to set reset positions
	AnimFunc.chain_anim_track($AttackPlayer.get_animation("Chomp_Attack"), $AttackPlayer.get_animation("Chomp_Reset"), ".:position")

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
	AnimFunc.adjust_all_keys($AttackPlayer.get_animation("Slice_Fail"), ".:position", target_position)
	AnimFunc.set_last_key_value($AttackPlayer.get_animation("Slice_Fail"), ".:position", Vector2(0,0))
	AnimFunc.adjust_all_keys($AttackPlayer.get_animation("Slice_Success"), ".:position", target_position)
	AnimFunc.set_last_key_value($AttackPlayer.get_animation("Slice_Success"), ".:position", Vector2(0,0))
	#work backwards
	AnimFunc.adjust_all_keys_backwards($AttackPlayer.get_animation("Slice_Attack"), ".:position", target_position)
	AnimFunc.chain_anim_track_backwards($AttackPlayer.get_animation("Slice_Attack"), $AttackPlayer.get_animation("Slice_Approach"), ".:position")

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
