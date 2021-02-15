extends BattlerAI

const DEFAULT_CHANCE = 0.75


func choose_action(actor: Battler, battlers: Array = []):
	# For now, we just choose a random action
	# It would be nice if there was AI
	yield(get_tree(), "idle_frame") #this is so it's async
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var rand_number = rng.randi_range(0, actor.actions.get_child_count()-1)
	return actor.actions.get_child(rand_number)


func choose_target(actor: Battler, action: CombatAction, battlers: Array = []):
	# Chooses a target to perform an action on
	yield(get_tree(), "idle_frame")
	var this_chance = randi() % 100
	var target_min_health = battlers[randi() % len(battlers)]

	if this_chance > DEFAULT_CHANCE:
		return [target_min_health]

	var min_health = target_min_health.stats.health
	for target in battlers:
		# don't attack battlers on your team
		if actor.party_member == target.party_member:
			continue

		if target.stats.health < min_health:
			target_min_health = target

	return [target_min_health]
