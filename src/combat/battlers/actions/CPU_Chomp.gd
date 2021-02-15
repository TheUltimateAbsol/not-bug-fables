extends CombatAction


func execute(targets):
	assert(initialized)
	assert(not actor.party_member)
	assert(targets.size() == 1)

	yield(actor.skin.battler_anim.play_chomp(targets[0], actor), "completed") #this might cause problems later on. How to scale?
	return true
