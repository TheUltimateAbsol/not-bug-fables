# Animated circular button that supports both keys and mouse input
# Reacts to mouse hover and focus events
extends Button

func initialize(action: CombatAction) -> void:
	$HBoxContainer/Name.text	= action.action_name
	disabled = not action.can_use()
	if disabled:
		modulate = Color("#555555")
