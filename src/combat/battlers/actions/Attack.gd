extends CombatAction


func execute(targets):
	assert(initialized)
	
	#Trash code for nonexistent conditions
	if actor.party_member and not targets:
		return false

	#for cpus (testing ????!)
	if not actor.party_member:
		for target in targets:
			yield(actor.skin.move_to(target), "completed")
			var hit = Hit.new(actor.stats.strength)
			target.take_damage(hit)
			yield(actor.get_tree().create_timer(1.0), "timeout")
			yield(return_to_start_position(), "completed")
	#actual code that does the attacking
	else:
		for target in targets:
			yield(actor.skin.battler_anim.play_jump(target), "completed") #this might cause problems later on. How to scale?
	return true
