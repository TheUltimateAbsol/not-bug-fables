extends CombatAction


func execute(targets):
	assert(initialized)
	assert(not actor.party_member)
	assert(targets.size() == 1)

	yield(actor.skin.battler_anim.play_ram(targets[0]), "completed") #this might cause problems later on. How to scale?
	return true
